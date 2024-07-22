#define N_BUNDLES 7
Bundle_t bundles [N_BUNDLES] = {
   {.n=1  , .l=4  , .kw=7  , .coe=3  , .coe_tl=2  , .r_ll=4  , .h=28 , .w=28 , .ci=1   , .co=8   , .w_kw2=25 , .t=3  , .p=1  , .cm=2  , .cm_p0=1  , .xp_words=1344  , .ib_out=1   , .w_bpt=84   , .w_bpt_p0=84   , .x_bpt=672     , .x_bpt_p0=672     , .o_words=640     , .o_bytes=320     , .x_pad=4  , .in_buffer_idx=-1 , .out_buffer_idx=0  , .add_out_buffer_idx=0 , .add_in_buffer_idx=-1, .is_bias=1  , .is_flatten=0  , .is_softmax=0  , .b_offset=0    , .b_val_shift=9  , .b_bias_shift=0  , .ca_nzero=0  , .ca_shift=12 , .ca_pl_scale=0  , .aa_nzero=0  , .aa_shift=0  , .aa_pl_scale=0  , .pa_nzero=1  , .pa_shift=0  , .pa_pl_scale=0  , .softmax_frac=0  , .softmax_max_f=0              , .csh=2  , .ch=14 , .csh_shift=1  , .pkh=3  , .psh=2  , .ph=7  , .psh_shift=0  , .csw=1  , .cw=28 , .csw_shift=0  , .pkw=4  , .psw=3  , .pw=10 , .psw_shift=1  , .pool=POOL_AVG  , .on=1  , .oh=7  , .ow=10 , .oc=8   , .header=      29695610579857627u, .debug_nhwc_words=560       },
   {.n=1  , .l=1  , .kw=1  , .coe=24 , .coe_tl=0  , .r_ll=7  , .h=7  , .w=10 , .ci=8   , .co=8   , .w_kw2=10 , .t=1  , .p=1  , .cm=20 , .cm_p0=8  , .xp_words=80    , .ib_out=2   , .w_bpt=96   , .w_bpt_p0=96   , .x_bpt=320     , .x_bpt_p0=320     , .o_words=960     , .o_bytes=480     , .x_pad=0  , .in_buffer_idx=0  , .out_buffer_idx=1  , .add_out_buffer_idx=1 , .add_in_buffer_idx=0 , .is_bias=1  , .is_flatten=0  , .is_softmax=0  , .b_offset=9    , .b_val_shift=9  , .b_bias_shift=0  , .ca_nzero=1  , .ca_shift=12 , .ca_pl_scale=0  , .aa_nzero=1  , .aa_shift=3  , .aa_pl_scale=3  , .pa_nzero=0  , .pa_shift=0  , .pa_pl_scale=0  , .softmax_frac=0  , .softmax_max_f=0              , .csh=1  , .ch=7  , .csh_shift=0  , .pkh=1  , .psh=1  , .ph=7  , .psh_shift=0  , .csw=1  , .cw=10 , .csw_shift=0  , .pkw=1  , .psw=1  , .pw=10 , .psw_shift=0  , .pool=POOL_NONE , .on=1  , .oh=7  , .ow=10 , .oc=8   , .header=      43276787871645768u, .debug_nhwc_words=560       },
   {.n=1  , .l=1  , .kw=7  , .coe=3  , .coe_tl=2  , .r_ll=7  , .h=7  , .w=10 , .ci=8   , .co=8   , .w_kw2=7  , .t=3  , .p=4  , .cm=2  , .cm_p0=2  , .xp_words=120   , .ib_out=3   , .w_bpt=168  , .w_bpt_p0=168  , .x_bpt=120     , .x_bpt_p0=120     , .o_words=960     , .o_bytes=480     , .x_pad=4  , .in_buffer_idx=1  , .out_buffer_idx=0  , .add_out_buffer_idx=-1, .add_in_buffer_idx=1 , .is_bias=1  , .is_flatten=0  , .is_softmax=0  , .b_offset=33   , .b_val_shift=9  , .b_bias_shift=0  , .ca_nzero=1  , .ca_shift=12 , .ca_pl_scale=0  , .aa_nzero=0  , .aa_shift=0  , .aa_pl_scale=0  , .pa_nzero=0  , .pa_shift=0  , .pa_pl_scale=0  , .softmax_frac=0  , .softmax_max_f=0              , .csh=1  , .ch=7  , .csh_shift=0  , .pkh=1  , .psh=1  , .ph=7  , .psh_shift=0  , .csw=1  , .cw=10 , .csw_shift=0  , .pkw=1  , .psw=1  , .pw=10 , .psw_shift=0  , .pool=POOL_NONE , .on=1  , .oh=7  , .ow=10 , .oc=8   , .header=      30188191789350987u, .debug_nhwc_words=560       },
   {.n=1  , .l=1  , .kw=5  , .coe=4  , .coe_tl=4  , .r_ll=7  , .h=7  , .w=10 , .ci=8   , .co=8   , .w_kw2=8  , .t=2  , .p=2  , .cm=4  , .cm_p0=4  , .xp_words=120   , .ib_out=4   , .w_bpt=240  , .w_bpt_p0=240  , .x_bpt=240     , .x_bpt_p0=240     , .o_words=960     , .o_bytes=480     , .x_pad=4  , .in_buffer_idx=0  , .out_buffer_idx=1  , .add_out_buffer_idx=-1, .add_in_buffer_idx=0 , .is_bias=1  , .is_flatten=0  , .is_softmax=0  , .b_offset=42   , .b_val_shift=9  , .b_bias_shift=0  , .ca_nzero=1  , .ca_shift=12 , .ca_pl_scale=0  , .aa_nzero=0  , .aa_shift=0  , .aa_pl_scale=0  , .pa_nzero=0  , .pa_shift=0  , .pa_pl_scale=0  , .softmax_frac=0  , .softmax_max_f=0              , .csh=1  , .ch=7  , .csh_shift=0  , .pkh=1  , .psh=1  , .ph=7  , .psh_shift=0  , .csw=1  , .cw=10 , .csw_shift=0  , .pkw=1  , .psw=1  , .pw=10 , .psw_shift=0  , .pool=POOL_NONE , .on=1  , .oh=7  , .ow=10 , .oc=8   , .header=      44121204210794570u, .debug_nhwc_words=560       },
   {.n=1  , .l=1  , .kw=3  , .coe=8  , .coe_tl=8  , .r_ll=7  , .h=7  , .w=10 , .ci=8   , .co=24  , .w_kw2=9  , .t=3  , .p=2  , .cm=6  , .cm_p0=2  , .xp_words=120   , .ib_out=5   , .w_bpt=216  , .w_bpt_p0=72   , .x_bpt=360     , .x_bpt_p0=120     , .o_words=1920    , .o_bytes=960     , .x_pad=4  , .in_buffer_idx=1  , .out_buffer_idx=0  , .add_out_buffer_idx=-1, .add_in_buffer_idx=-1, .is_bias=1  , .is_flatten=0  , .is_softmax=0  , .b_offset=50   , .b_val_shift=9  , .b_bias_shift=0  , .ca_nzero=0  , .ca_shift=12 , .ca_pl_scale=0  , .aa_nzero=0  , .aa_shift=0  , .aa_pl_scale=0  , .pa_nzero=0  , .pa_shift=0  , .pa_pl_scale=0  , .softmax_frac=0  , .softmax_max_f=0              , .csh=1  , .ch=7  , .csh_shift=0  , .pkh=1  , .psh=1  , .ph=7  , .psh_shift=0  , .csw=1  , .cw=10 , .csw_shift=0  , .pkw=1  , .psw=1  , .pw=10 , .psw_shift=0  , .pool=POOL_NONE , .on=1  , .oh=7  , .ow=10 , .oc=24  , .header=      38632443238154313u, .debug_nhwc_words=1680      },
   {.n=1  , .l=1  , .kw=1  , .coe=24 , .coe_tl=0  , .r_ll=7  , .h=7  , .w=10 , .ci=24  , .co=10  , .w_kw2=10 , .t=1  , .p=2  , .cm=20 , .cm_p0=4  , .xp_words=80    , .ib_out=6   , .w_bpt=240  , .w_bpt_p0=48   , .x_bpt=800     , .x_bpt_p0=160     , .o_words=5600    , .o_bytes=2800    , .x_pad=0  , .in_buffer_idx=0  , .out_buffer_idx=1  , .add_out_buffer_idx=-1, .add_in_buffer_idx=-1, .is_bias=1  , .is_flatten=1  , .is_softmax=0  , .b_offset=74   , .b_val_shift=9  , .b_bias_shift=0  , .ca_nzero=0  , .ca_shift=12 , .ca_pl_scale=0  , .aa_nzero=0  , .aa_shift=0  , .aa_pl_scale=0  , .pa_nzero=0  , .pa_shift=0  , .pa_pl_scale=0  , .softmax_frac=0  , .softmax_max_f=0              , .csh=1  , .ch=7  , .csh_shift=0  , .pkh=1  , .psh=1  , .ph=7  , .psh_shift=0  , .csw=1  , .cw=10 , .csw_shift=0  , .pkw=1  , .psw=1  , .pw=10 , .psw_shift=0  , .pool=POOL_NONE , .on=1  , .oh=1  , .ow=1  , .oc=700 , .header=      42995312893886536u, .debug_nhwc_words=700       },
   {.n=1  , .l=1  , .kw=1  , .coe=24 , .coe_tl=0  , .r_ll=1  , .h=1  , .w=1  , .ci=700 , .co=10  , .w_kw2=1  , .t=1  , .p=35 , .cm=20 , .cm_p0=20 , .xp_words=8     , .ib_out=-1  , .w_bpt=240  , .w_bpt_p0=240  , .x_bpt=80      , .x_bpt_p0=80      , .o_words=10      , .o_bytes=40      , .x_pad=0  , .in_buffer_idx=1  , .out_buffer_idx=-1 , .add_out_buffer_idx=-1, .add_in_buffer_idx=-1, .is_bias=0  , .is_flatten=0  , .is_softmax=1  , .b_offset=98   , .b_val_shift=0  , .b_bias_shift=0  , .ca_nzero=1  , .ca_shift=3  , .ca_pl_scale=0  , .aa_nzero=0  , .aa_shift=0  , .aa_pl_scale=0  , .pa_nzero=0  , .pa_shift=0  , .pa_pl_scale=0  , .softmax_frac=3  , .softmax_max_f=0.875          , .csh=1  , .ch=1  , .csh_shift=0  , .pkh=1  , .psh=1  , .ph=1  , .psh_shift=0  , .csw=1  , .cw=1  , .csw_shift=0  , .pkw=1  , .psw=1  , .pw=1  , .psw_shift=0  , .pool=POOL_NONE , .on=1  , .oh=1  , .ow=1  , .oc=10  , .header=      44121212804923392u, .debug_nhwc_words=10        }
};

#define X_BITS_L2   2
#define W_BITS_L2   2
#define KH_MAX      9
#define PE_ROWS     8
#define PE_COLS     24

#define N_OUT_BUF   2
#define N_ADD_BUF   2
#define WB_BYTES    13072
#define W_BYTES     12876
#define X_BYTES     672
#define O_WORDS     10
#define O_WORDS_MAX 5600
#define O_BYTES_MAX 2800
#define X_BYTES_ALL 6192
#define NHWC_WORDS  6272
#define Y_TYPE      int32_t
#define B_TYPE      int16_t
#define O_TYPE      float
#define B_WORDS     98
#define AXI_WIDTH   32
#define MEM_BASEADDR    0x20000000
#define CONFIG_BASEADDR 0xB0000000
#define DATA_DIR   "../vectors"

static const uint8_t X_POSITION_INVERTED_MASKS [] = { 240, 15 };
