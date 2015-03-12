###
file: baler.coffee
author: Narate Taerat (narate at ogc dot us)

This is a javascript package for communicating with bhttpd and constructing
Baler Web GUI widgets.

###

define ["jquery", "baler_config", "lazy_html"], ($, bcfg, _) -> baler =
    balerd:
        addr: (()->
            host = window.location.hostname
            if (!host)
                host = 'localhost'
            port = window.location.port
            if (bcfg.bhttpd.host)
                host = bcfg.bhttpd.host
            if (bcfg.bhttpd.port)
                port = bcfg.bhttpd.port
            hostport = host
            if (port)
                hostport += ":#{port}"
            return hostport
        )()

    ts2datetime: (ts) ->
        date = new Date(ts*1000)
        y = date.getYear() + 1900
        m = date.getMonth() + 1
        d = date.getDate()
        hh = date.getHours()
        mm = date.getMinutes()
        ss = date.getSeconds()
        return "#{y}-#{m}-#{d} #{hh}:#{mm}:#{ss}"

    tkn2html : (tok) -> "<span class='baler_#{tok.tok_type}'>#{tok.text}</span>"

    msg2html : (msg) ->
        baler.tkn2html(tok) for tok in msg

    query: (param, cb) ->
        url = "http://#{baler.balerd.addr}/query"
        $.getJSON(url, param, cb)

    query_img: (param, cb) ->
        req = new XMLHttpRequest()
        url = "http://#{baler.balerd.addr}/query"
        first = 1
        for k,v of param
            if first
                c = '?'
                first = 0
            else
                c = '&'
            url += "#{c}#{k}=#{v}"
        req.onload = () -> cb(req.response, "", req)
        req.open("GET", url, true)
        req.responseType = 'arraybuffer'
        req.send()
        return 0

    get_test: (param, cb) ->
        url = "http://#{baler.balerd.addr}/test"
        $.getJSON(url, param, cb)

    get_ptns : (cb) ->
        baler.query({"type": "ptn"}, cb)

    get_meta : (cb) ->
        baler.query({"type": "meta"}, cb)

    msg_cmp: (msg0, msg1) ->
        if msg0.ts == msg1.ts
            if msg0.host == msg1.host
                return 0
            if msg0.host < msg1.host
                return -1
            return 1
        if msg0.ts < msg1.ts
            return -1
        return 1

    Disp: class Disp
        domobj: undefined
        element_type: undefined
        constructor: (@element_type) ->
            @domobj = _.tag(@element_type)

    TokDisp: class TokDisp extends Disp
        tok: undefined
        constructor: (@tok) ->
            @domobj = _.span({class: "baler_#{@tok.tok_type}"}, @tok.text)

    MsgDisp: class MsgDisp extends Disp
        msg: undefined
        constructor: (@msg) ->
            @domobj = _.span(null, t.domobj for t in \
                                (new TokDisp(tok) for tok in @msg))

    MsgLstEnt: class MsgLstEnt extends Disp
        msg: undefined
        constructor: (@msg) ->
            m = new MsgDisp(@msg.msg)
            ts = _.span({class: "timestamp"}, @msg.ts)
            host = _.span({class: "host"}, @msg.host)
            @domobj = _.li({class: "MsgLstEnt"}, ts, " ", host, " ", m.domobj)

    PtnLstEnt: class PtnLstEnt extends Disp
        ptn: undefined
        constructor: (@ptn) ->
            m = new MsgDisp(@ptn.msg)
            @domobj = _.li({class: "PtnLstEnt"}, "[#{@ptn.ptn_id}]:", m.domobj)

    GrpLstEnt: class GrpLstEnt extends Disp
        subdom: undefined
        namedom: undefined
        name: undefined
        gid: undefined
        expanded: true
        toggleExpanded: () ->
            @expanded = !@expanded
            if @expanded
                @subdom.style.display = ""
            else
                @subdom.style.display = "none"

        namedom_onClick: (_this_) ->
            _this_.toggleExpanded()

        constructor: (@name, @gid) ->
            @namedom = _.div({class: "GrpLstEnt_name"}, @name)
            @subdom = _.ul()
            @domobj = _.li({class: "GrpLstEnt"}, @namedom, @subdom)

            fn = @namedom_onClick
            obj = this
            @namedom.onclick = () -> fn(obj)

        addPtnLstEnt: (p) ->
            @subdom.appendChild(p.domobj)

    # -- end GrpLstEnt class -- #


    PtnTable: class PtnTable extends Disp
        ptns: undefined
        groups: undefined
        ptns_ent: [] # ptns_dom[ptn_id] is PtnLstEnt of ptn_id
        groups_ent: [] # groups_dom[gid] is GrpLstEnt of gid

        constructor: (__ptns__, @groups) ->
            @domobj = _.ul({class: "PtnTable"})

            @ptns = []
            for p in __ptns__
                @ptns[p.ptn_id] = p
            for pid in Object.keys(@ptns)
                # ptn dom object creation
                ptn = @ptns[pid]
                p = @ptns_ent[pid] = new PtnLstEnt(ptn)
                # group dom object creation
                gid = @groups[pid]
                if not gid
                    gid = 0
                g = @groups_ent[gid]
                if not g
                    g = @groups_ent[gid] = new GrpLstEnt("#{gid}", gid)
                    @domobj.appendChild(g.domobj)
                g.addPtnLstEnt(p)

        sort: () ->
            @groups_ent.sort (a,b) ->
                if a.gid == b.gid
                    return 0
                if a.gid < b.gid
                    return -1
                return 1
            for g in @groups_ent
                if g
                    @domobj.appendChild(g.domobj)
            0
    # -- end PtnTable class -- #


    MsgTableControl: class MsgTableControl extends Disp
        dom:
            root: null
            input:
                ts0: null
                ts1: null
                host_ids: null
                ptn_ids: null
            apply_btn: null
            up_btn: null
            down_btn: null
            uup_btn: null
            ddown_btn: null

        dom_input_label_placeholder:
            ts0: ["Timestamp begin: ", "yyyy-mm-dd HH:MM:SS"]
            ts1: ["Timestamp end: ", "yyyy-mm-dd HH:MM:SS"]
            host_ids: ["Host list: ", "example: 1,2,5-10"]
            ptn_ids: ["Pattern ID list: ", "example: 1,2,5-10"]

        msgTable: undefined

        getQueryInput: () ->
            q = {}
            for k,obj of @dom.input when obj.value
                q[k] = obj.value
            return q

        on_apply_btn_click: (event) ->
            query = @getQueryInput()
            query.type = "msg"
            query.dir = if query.ts0 then "fwd" else "bwd"
            @msgTable.query(query)

        getOlder: (event, n) ->
            @msgTable.fetchOlder(n)

        constructor: (@msgTable) ->
            _this_ = this
            ul = _.ul({style: "list-style: none"})
            for k, [lbl, plc] of @dom_input_label_placeholder
                input = @dom.input[k] = _.input()
                input.placeholder = plc
                li = _.li(null, _.span(null, lbl), input)
                ul.appendChild(li)
            btns = [
                @dom.apply_btn = _.button(null, "apply"),
                @dom.uup_btn = _.button(null, "\u21c8"),
                @dom.up_btn = _.button(null, "\u21bf"),
                @dom.down_btn = _.button(null, "\u21c2"),
                @dom.ddown_btn = _.button(null, "\u21ca")
            ]

            @dom.apply_btn.onclick = (event) -> _this_.on_apply_btn_click(event)
            @dom.uup_btn.onclick = (event) -> _this_.msgTable.fetchOlder(5)
            @dom.up_btn.onclick = (event) -> _this_.msgTable.fetchOlder(1)
            @dom.down_btn.onclick = (event) -> _this_.msgTable.fetchNewer(1)
            @dom.ddown_btn.onclick = (event) -> _this_.msgTable.fetchNewer(5)

            @dom.root = _.div({class: "MsgTableControl"}, ul, btns)
            @domobj = @dom.root

    # -- end MsgTableControl class -- #


    MsgTable: class MsgTable extends Disp
        query_param:
            type: "msg"
            ts0: undefined
            ts1: undefined
            host_ids: undefined
            ptn_ids: undefined
            session_id: undefined
            n: 10
            dir: "bwd"

        tableSize: 15

        dom:
            root: null
            ul: null

        msgent_list: [] # Current list of MsgLstEnt's  .. use msg.ref as key
        msgent_first: undefined
        msgent_last: undefined

        constructor: (tableSize) ->
            if tableSize
                @tableSize = tableSize
            @dom.ul = _.ul({style: "list-style: none"})
            @domobj = @dom.root = _.div(null, @dom.ul)

        clearTable: () ->
            ul = @dom.ul
            ul.removeChild(ul.firstChild) while (ul.firstChild)
            @msgent_list = []

        initTable: (msgs) ->
            @clearTable()
            if @query_param.dir == "fwd"
                @__addFn = @addNewerEnt
            else
                @__addFn = @addOlderEnt
            for msg in msgs
                ent = new MsgLstEnt(msg)
                @__addFn(ent, msg.ref)

        addOlderEnt: (ent, ref) ->
            ent.domobj.msgref = ref
            @msgent_list[ref] = ent
            @dom.ul.insertBefore(ent.domobj, @dom.ul.firstChild)

        addNewerEnt: (ent, ref) ->
            ent.domobj.msgref = ref
            @msgent_list[ref] = ent
            @dom.ul.appendChild(ent.domobj)

        removeMsg: (msgref) ->
            ent = @msgent_list[msgref]
            delete @msgent_list[msgref]
            @dom.ul.removeChild(ent.domobj)

        removeOlderEnt: (n) ->
            if not n
                return
            for i in [1..n]
                @removeMsg(@dom.ul.firstChild.msgref)

        removeNewerEnt: (n) ->
            if not n
                return
            for i in [1..n]
                @removeMsg(@dom.ul.lastChild.msgref)

        __addFn: undefined
        __removeFn: undefined

        updateTable: (msgs) ->
            window.msgs = msgs
            old_refs = Object.keys(@msgent_list)
            if @query_param.dir == "fwd"
                @__addFn = @addNewerEnt
                @__removeFn = @removeOlderEnt
            else
                @__addFn = @addOlderEnt
                @__removeFn = @removeNewerEnt

            ###
            # For debugging #
            for elm in @dom.ul.childNodes
                elm.classList.remove("NewRow")
            # --------------#
            ###
            count = 0
            for msg in msgs
                if @msgent_list[msg.ref]
                    continue
                ent = new MsgLstEnt(msg)
                # ent.domobj.classList.add("NewRow")
                # _.addChildren(ent.domobj, " ##{count}")
                count++
                @__addFn(ent, msg.ref)

            @__removeFn(count)

        query_cb: (data, textStatus, jqXHR) ->
            if not data.session_id
                cosole.log("MsgTable query error
                    (check __msgtable_datat for debugging)")
                return -1
            if @query_param.session_id != data.session_id
                # New bhttpd session, treat as new table
                @query_param.session_id = data.session_id
                @initTable(data.msgs)
                return 0
            # Reaching here means updating the table ...
            @updateTable(data.msgs)

        query: (param) ->
            if param
                # Destroy old session_id
                if @query_param.session_id
                    url = "http://#{baler.balerd.addr}/query/destroy_session?"+
                        "session_id=#{@query_param.session_id}"
                    $.ajax(url, {})
                @query_param = param
            @query_param.n ?= @tableSize
            _this_ = this
            baler.query(@query_param, (data, textStatus, jqXHR) ->
                _this_.query_cb(data, textStatus, jqXHR)
            )

        fetchOlder: (n) ->
            @query_param.n = n
            if @query_param.dir == "fwd"
                @query_param.n += @tableSize - 1
            @query_param.dir = "bwd"
            @query()

        fetchNewer: (n) ->
            this.query_param.n = n
            if @query_param.dir == "bwd"
                @query_param.n += @tableSize - 1
            this.query_param.dir = "fwd"
            this.query()

    # -- end MsgTable class -- #


    HeatMapLayer: class HeatMapLayer extends Disp
        name: "Layer"
        color: "red"
        ts_begin: 1425963600
        node_begin: 1
        ctxt: undefined
        pxl: undefined
        npp: 1 # Node per pixel
        spp: 3600 # seconds per pixel
        mouseDown: false
        mouseDownPos:
            x: undefined
            y: undefined
        oldImg: undefined
        ptn_ids: undefined
        bound:
            node:
                min: null
                max: null
            ts:
                min: null
                max: null
        base_color: [255, 0, 0]

        constructor: (@width, @height) ->
            _this_ = this
            @domobj = _.canvas({width: width, height: height})
            @domobj.style.position = "absolute"
            @domobj.style.pointerEvents = "none"
            @ctxt = @domobj.getContext("2d")
            @pxl = @ctxt.createImageData(1, 1)
            @ptn_ids = ""

        updateImageCb: (_data, textStatus, jqXHR, ts0, n0, _w, _h) ->
            img = @ctxt.createImageData(_w, _h)
            i = 0
            data = new Uint32Array(_data)
            while i < data.length
                img.data[i*4] = @base_color[0]
                img.data[i*4+1] = @base_color[1]
                img.data[i*4+2] = @base_color[2]
                img.data[i*4+3] = data[i]
                i++

            _x = (ts0 - @ts_begin) / @spp
            _y = (n0 - @node_begin) / @npp
            @ctxt.clearRect(_x, _y, _w, _h)
            @ctxt.putImageData(img, _x, _y)

        clearImage: (x = 0, y = 0, width = @width, height = @height) ->
            @ctxt.clearRect(x, y, width, height)

        updateImage: (_x = 0, _y = 0, _width = @width, _height = @height) ->
            _this_ = this
            ts0 = @ts_begin + @spp*_x
            ts1 = ts0 + @spp*_width
            n0 = @node_begin + @npp*_y
            n0 = 1 if n0 < 1
            n1 = n0 + @npp*_height
            baler.query_img({
                    type: "img2",
                    ts_begin: ts0,
                    host_begin: n0,
                    #ptn_ids: _this_.ptn_ids.join(","),
                    ptn_ids: @ptn_ids,
                    img_store: "3600-1",
                    width: _width,
                    height: _height,
                    spp: @spp,
                    npp: @npp,
                },
                (data, textStatus, jqXHR)->
                    _this_.updateImageCb(data, textStatus, jqXHR, ts0, n0,
                                                            _width, _height)
            )
            return 0

        onMouseMove: (event) ->
            if ! @mouseDown
                return 0
            dx = event.pageX - @mouseDownPos.x
            dy = event.pageY - @mouseDownPos.y

            @ctxt.clearRect(0, 0, @width, @height)
            @ctxt.putImageData(@oldImg, dx, dy)
            return 0

        onMouseDown: (event) ->
            @mouseDownPos.x = event.pageX
            @mouseDownPos.y = event.pageY
            @oldImg = @ctxt.getImageData(0, 0, @width, @height)
            @mouseDown = true

        onMouseUp: (event) ->
            @mouseDown = false
            dx = event.pageX - @mouseDownPos.x
            dy = event.pageY - @mouseDownPos.y
            fx = if dx < 0 then @width + dx else 0
            fy = if dy < 0 then @height + dy else 0
            fw = Math.abs(dx)
            fh = Math.abs(dy)
            ts_begin = @ts_begin - @spp*dx
            node_begin = @node_begin - @npp*dy
            @ts_begin = ts_begin
            @node_begin = node_begin
            if fw
                @updateImage(fx, 0, fw, @height)
            if fh
                @updateImage(0, fy, @width, fh)

    HeatMapDisp: class HeatMapDisp extends Disp
        width: 0
        height: 0
        ts_begin: 1425963600
        node_begin: 1
        npp: 1
        spp: 3600
        layers: undefined

        constructor: (@width=400, @height=400) ->
            _this_ = this
            @domobj = _.div({class: "HeatMapDisp"})
            @domobj.style.position = "relative"
            @domobj.style.width = @width
            @domobj.style.height = @height
            @domobj.onmousedown = (event) -> _this_.onMouseDown(event)
            @domobj.onmouseup = (event) -> _this_.onMouseUp(event)
            @domobj.onmousemove = (event) -> _this_.onMouseMove(event)
            @layerDescList = []
            @layers = []
            @mouseDown = 0
            @mouseDownPos = {x: 0, y: 0}

        createLayer: (name, ptn_ids, base_color = [255, 0, 0]) ->
            layer = new HeatMapLayer(@width, @height)
            layer.name = name
            layer.base_color = base_color
            layer.ptn_ids = ptn_ids
            layer.ts_begin = @ts_begin
            layer.node_begin = @node_begin
            layer.npp = @npp
            layer.spp = @spp

            layer.updateImage()

            @layers.push(layer)
            @domobj.appendChild(layer.domobj)
            # for debugging
            layer.domobj.setAttribute("name", name)
            return @layers.length - 1

        destroyLayer: (idx) ->
            layer = @layers.splice(idx, 1)
            if (!layer)
                return
            @domobj.removeChild(layer[0].domobj)

        disableLayer: (idx) ->
            @layers[idx].domobj.hidden = 1

        enableLayer: (idx) ->
            layer = @layers[idx]
            layer.clearImage()
            layer.ts_begin = @ts_begin
            layer.node_begin = @node_begin
            layer.updateImage()
            layer.domobj.hidden = false

        onMouseUp: (event) ->
            if not @mouseDown
                return
            @mouseDown = false
            dx = event.pageX - @mouseDownPos.x
            dy = event.pageY - @mouseDownPos.y
            ts_begin = @ts_begin - @spp*dx
            node_begin = @node_begin - @npp*dy
            @ts_begin = ts_begin
            @node_begin = node_begin
            for l in @layers when !l.domobj.hidden
                l.onMouseUp(event)
            return 0

        onMouseDown: (event) ->
            if @mouseDown
                return
            @mouseDown = true
            @mouseDownPos.x = event.pageX
            @mouseDownPos.y = event.pageY
            for l in @layers when !l.domobj.hidden
                l.onMouseDown(event)
            return 0

        onMouseMove: (event) ->
            if not @mouseDown
                return 0
            for l in @layers when !l.domobj.hidden
                l.onMouseMove(event)
            return 0

        updateLayers: (x=0, y=0, width=@width, height=@height) ->
            for l in @layers when !l.domobj.hidden
                l.updateImage(x, y, width, height)
            return 0

    HeatMapDispCtrl: class HeatMapDispCtrl extends Disp
        hmap: undefined

        dom_input_label_placeholder:
            name: ["Layer name: ", "Any name ..."]
            ptn_ids: ["Pattern ID list: ", "example: 1,2,5-10"]

        dom_input: undefined
        dom_add_btn: undefined
        dom_layer_list: undefined

        constructor: (@hmap) ->
            _this_ = this
            @dom_input = {}
            @domobj = _.div({class: "HeatMapDispCtrl"})
            ul = _.ul({style: "list-style: none"})
            for k,[lbl,plc] of @dom_input_label_placeholder
                inp = @dom_input[k] = _.input()
                inp.placeholder = plc
                li = _.li(null, lbl, inp)
                ul.appendChild(li)
            @dom_add_btn = _.button(null, "add")
            @dom_add_btn.onclick = () -> _this_.onAddBtnClick()
            @dom_layer_list = _.ul({style: "list-style: none"})

            # Laying out the component
            @domobj.appendChild(ul)
            @domobj.appendChild(@dom_add_btn)
            @domobj.appendChild(@dom_layer_list)
            return this

        onAddBtnClick: () ->
            _this_ = this
            name = @dom_input["name"].value
            ptn_ids = @dom_input["ptn_ids"].value
            idx = @hmap.createLayer(name, ptn_ids, [255, 0, 0])
            @dom_input["name"].value = ""
            @dom_input["ptn_ids"].value = ""

            chk = _.input({type: "checkbox"})
            chk.checked = 1
            chk.layer = @hmap.layers[idx]
            chk.onchange = () -> _this_.onLayerCheckChange(chk)

            rmbtn = _.button(null, "x")
            rmbtn.layer = @hmap.layers[idx]
            rmbtn.onclick = () -> _this_.onRmBtnClicked(rmbtn)

            li = _.li(null, chk, name, ":", ptn_ids, " ", rmbtn)

            rmbtn.li = li
            @dom_layer_list.appendChild(li)

        onLayerCheckChange: (chk) ->
            idx = @hmap.layers.indexOf(chk.layer)
            if chk.checked
                @hmap.enableLayer(idx)
            else
                @hmap.disableLayer(idx)

        onRmBtnClicked: (btn) ->
            idx = @hmap.layers.indexOf(btn.layer)
            @dom_layer_list.removeChild(btn.li)
            @hmap.destroyLayer(idx)
            console.log("idx: #{idx}")


    Parent: class Parent
        constructor: (@name) ->
            console.log("parent constructor")

        say: (text) ->
            console.log("#{@name}: #{text}")

    Child: class Child extends Parent
        constructor: (@name) ->
            super(name)
            console.log("child constructor")

        say: (text) ->
            console.log("child .. #{@name}: #{text}")


# END OF FILE #