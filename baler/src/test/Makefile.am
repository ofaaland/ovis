bin_PROGRAMS =

AM_CFLAGS = -I$(top_srcdir)/src

bmap_test_SOURCES = bmap_test.c
bmap_test_LDADD = ../baler/libbaler.la -lpthread -ldl
bin_PROGRAMS += bmap_test

bset_test_SOURCES = bset_test.c
bset_test_LDADD = ../baler/libbaler.la
bin_PROGRAMS += bset_test

bstr_dist_u32_test_SOURCES = bstr_dist_u32_test.c
bstr_dist_u32_test_LDADD = ../baler/libbaler.la
bin_PROGRAMS += bstr_dist_u32_test

bhash_test_SOURCES = bhash_test.c
bhash_test_LDADD = ../baler/libbaler.la
bin_PROGRAMS += bhash_test

bheap_test_SOURCES = bheap_test.c
bheap_test_LDADD = ../baler/libbaler.la
bin_PROGRAMS += bheap_test

bmhash_test_SOURCES = bmhash_test.c
bmhash_test_LDADD = ../baler/libbaler.la
bin_PROGRAMS += bmhash_test

bqpos_test_SOURCES = bqpos_test.c
bqpos_test_LDADD = ../baler/libbaler.la ../query/libbquery.la
bin_PROGRAMS += bqpos_test

bmqueue_test_SOURCES = bmqueue_test.c
bmqueue_test_LDADD = ../baler/libbaler.la -lpthread
bin_PROGRAMS += bmqueue_test
