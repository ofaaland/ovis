/*
 * Copyright (c) 2013 Open Grid Computing, Inc. All rights reserved.
 * Copyright (c) 2013 Sandia Corporation. All rights reserved.
 * Under the terms of Contract DE-AC04-94AL85000, there is a non-exclusive
 * license for use of this work by or on behalf of the U.S. Government.
 * Export of this program may require a license from the United States
 * Government.
 *
 * This software is available to you under a choice of one of two
 * licenses.  You may choose to be licensed under the terms of the GNU
 * General Public License (GPL) Version 2, available from the file
 * COPYING in the main directory of this source tree, or the BSD-type
 * license below:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *      Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *      Redistributions in binary form must reproduce the above
 *      copyright notice, this list of conditions and the following
 *      disclaimer in the documentation and/or other materials provided
 *      with the distribution.
 *
 *      Neither the name of Sandia nor the names of any contributors may
 *      be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 *      Neither the name of Open Grid Computing nor the names of any
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *      Modified source versions must be plainly marked as such, and
 *      must not be misrepresented as being the original software.
 *
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/**
 * \file lustre_sampler.h
 * \brief Lustre sampler header file.
 *
 * This header file contains contents shared among multiple Lustre samplers,
 * such as possible keys in a regular 'stats' file.
 */
#ifndef __LUSTRE_SAMPLER_H
#define __LUSTRE_SAMPLER_H

#include <stdio.h>
#include <sys/queue.h>
#include "str_map.h"

#include "ldms.h"
#include "ldmsd.h"

LIST_HEAD(str_list_head, str_list);
struct str_list {
	char *str;
	LIST_ENTRY(str_list) link;
};

void free_str_list(struct str_list_head *h);

#define __ALEN(x) (sizeof(x)/sizeof(*x))
#define STATS_KEY_LEN (__ALEN(stats_key))
char *stats_key[] = {
	/* Lustre RPC counter*/
	"req_waittime",
	"req_qdepth",
	"req_active",
	"req_timeout",
	"reqbuf_avail",

	/* Extra Opcodes counters */
	"ldlm_glimpse_enqueue",
	"ldlm_plain_enqueue",
	"ldlm_extent_enqueue",
	"ldlm_flock_enqueue",
	"ldlm_ibits_enqueue",
	"mds_reint_setattr",
	"mds_reint_create",
	"mds_reint_link",
	"mds_reint_unlink",
	"mds_reint_rename",
	"mds_reint_open",
	"mds_reint_setxattr",
	"read_bytes",
	"write_bytes",

	/* rpc opcode counter */
	"ost_reply",
	"ost_getattr",
	"ost_setattr",
	"ost_read",
	"ost_write",
	"ost_create",
	"ost_destroy",
	"ost_get_info",
	"ost_connect",
	"ost_disconnect",
	"ost_punch",
	"ost_open",
	"ost_close",
	"ost_statfs",
	"ost_sync",
	"ost_set_info",
	"ost_quotacheck",
	"ost_quotactl",
	"ost_quota_adjust_qunit",

	"mds_getattr",
	"mds_getattr_lock",
	"mds_close",
	"mds_reint",
	"mds_readpage",
	"mds_connect",
	"mds_disconnect",
	"mds_getstatus",
	"mds_statfs",
	"mds_pin",
	"mds_unpin",
	"mds_sync",
	"mds_done_writing",
	"mds_set_info",
	"mds_quotacheck",
	"mds_quotactl",
	"mds_getxattr",
	"mds_setxattr",
	"mds_writepage",
	"mds_is_subdir",
	"mds_get_info",
	"mds_hsm_state_get",
	"mds_hsm_state_set",
	"mds_hsm_action",
	"mds_hsm_progress",
	"mds_hsm_request",
	"mds_hsm_ct_register",
	"mds_hsm_ct_unregister",
	"mds_swap_layouts",

	"ldlm_enqueue",
	"ldlm_convert",
	"ldlm_cancel",
	"ldlm_bl_callback",
	"ldlm_cp_callback",
	"ldlm_gl_callback",
	"ldlm_set_info",

	"mgs_connect",
	"mgs_disconnect",
	"mgs_exception",
	"mgs_target_reg",
	"mgs_target_del",
	"mgs_set_info",
	"mgs_config_read",

	"obd_ping",
	"llog_origin_handle_cancel",
	"obd_quota_callback",
	"dt_index_read",

	"llog_origin_handle_create",
	"llog_origin_handle_next_block",
	"llog_origin_handle_read_header",
	"llog_origin_handle_write_rec",
	"llog_origin_handle_close",
	"llog_origin_connect",
	"llog_catinfo",
	"llog_origin_handle_prev_block",
	"llog_origin_handle_destroy",

	"quota_acquire",
	"quota_release",

	"seq_query",
	"sec_ctx_init",
	"sec_ctx_init_cont",
	"sec_ctx_fini",

	"fld_query",
	"update_obj",
}; /* stats_key[] */

LIST_HEAD(lustre_svc_stats_head, lustre_svc_stats);
struct lustre_svc_stats {
	LIST_ENTRY(lustre_svc_stats) link;
	char *path;
	FILE *f;
	struct str_map *key_id_map;
	void *metrics[0];
};

/**
 * lustre_svc_stats allocation.
 * \param path The path of the stats file that ties to the structure.
 * \param mlen The number of metrics for lustre_svc_stats structure.
 */
struct lustre_svc_stats* lustre_svc_stats_alloc(const char *path, int mlen);

/**
 * Free the \c lss.
 * \param lss The ::lustre_svc_stats to free.
 */
void lustre_svc_stats_free(struct lustre_svc_stats *lss);

/**
 * Free a list of ::lustre_svc_stats.
 * \param h The head of the list.
 */
void lustre_svc_stats_list_free(struct lustre_svc_stats_head *h);

/**
 * Routine for a stats file.
 * \returns 0 on success.
 * \returns Error code on error.
 */
int stats_construct_routine(ldms_set_t set,
			    const char *stats_path,
			    const char *metric_name_base,
			    struct lustre_svc_stats_head *stats_head,
			    char **keys, int nkeys,
			    struct str_map *key_id_map);

/**
 * Set message log function to \c f.
 * \param f The pointer to logging function.
 */
void lustre_sampler_set_msglog(ldmsd_msg_log_f f);

/**
 * \brief Sample the metrics in \c lss.
 * \param lss The ::lustre_svc_stats structure.
 */
int lss_sample(struct lustre_svc_stats *lss);

/**
 * Construct ::str_list out of comma-separated \c strlist.
 * \param strlist The comma-separated string.
 * \returns Pointer to ::str_list_head.
 */
struct str_list_head* construct_str_list(const char *strlist);

/**
 * Construct string list of directories inside the given \c path.
 * \param path The path (directory) to query from.
 * \returns The list head.
 */
struct str_list_head* construct_dir_list(const char *path);

#endif /* __LUSTRE_SAMPLER_H */