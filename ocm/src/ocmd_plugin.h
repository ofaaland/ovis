#ifndef __OCMD_PLUGIN_H
#define __OCMD_PLUGIN_H

#include <sys/queue.h>

#include "ovis_util/util.h"
#include "ocm.h"

struct ocm_receiver {
	char hostname[128];
	uint16_t port;
	LIST_ENTRY(ocm_receiver) entry;
};

typedef LIST_HEAD(_ocm_recv_head_, ocm_receiver) * ocm_recv_head_t;

typedef struct ocmd_plugin* ocmd_plugin_t;

/**
 * OCMD Plugin structure.
 *
 * OCMD Plugin must implement the function:
 * <pre>
 * struct ocmd_plugin* ocmd_plugin_create(void (*log_fn)(const char *fmt, ...),
 *					  struct attr_value_list *avl);
 * </pre>
 *
 * The \c create function should create and initialize \c ocmd_plugin.
 * Attribute-value list (\c avl) is provided for plugin initialization.
 * Upon erorr, the \c create function should return NULL and set errno
 * appropriately.
 *
 * The \c log_fn is a log function for the plugin to log its messages.
 *
 * The create function should return \c ocmd_plugin structure described below.
 */
struct ocmd_plugin {
	/**
	 * Get configuration for \c key.
	 *
	 * The plugin should put configuration for \c key into \c buff using
	 * ::ocm_cfg_buff_add_verb() ::ocm_cfg_buff_add_av() and
	 * ::ocm_cfg_buff_add_cmd_as_av().
	 *
	 * \returns 0 on success.
	 * \returns Error code on error.
	 */
	int (*get_config)(ocmd_plugin_t p, const char *key, struct ocm_cfg_buff *buff);

	/**
	 * Log function.
	 *
	 * This function will be set to the same \c log_fn in \c
	 * ocmd_plugin_create() so that the plugin can use this function for
	 * logging.
	 *
	 */
	void (*log_fn)(const char *fmt, ...);

	void (*destroy)(ocmd_plugin_t p);
};

#endif