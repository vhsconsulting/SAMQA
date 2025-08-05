create or replace package samqa.pc_sam_gp_intgrtn as
    g_date date := trunc(sysdate);
    type ty_rc_gp_rcv_pmt is record (
            acc_id      number,
            acnt_typ    varchar2(10),
            cstvnd_id   varchar2(15),
            cstvnd_nm   varchar2(64),
            address_id  varchar2(15),
            stckd       varchar2(1),
            outside_inv varchar2(1),
            status      varchar2(1),
            entity_typ  varchar2(1),
            pers_id     number,
            entrp_id    number
    );
    type ty_tb_gp_cstmr_acc is
        table of ty_rc_gp_rcv_pmt index by pls_integer;
    type ty_tb_gp_vndr_acc is
        table of ty_rc_gp_rcv_pmt index by pls_integer;
    type ty_rc_gp_trnscn is record (
            batch_id  varchar2(15),
            cstvnd_id varchar2(15),
            invdoc_no varchar2(17),
            docmnt_dt varchar2(10),
            amnt      varchar2(15)
    );
    type ty_tb_gp_ar_trnscn is
        table of ty_rc_gp_trnscn;
    type ty_tb_gp_ap_trnscn is
        table of ty_rc_gp_trnscn;
    type ty_rc_payment is record (
            batch_id    varchar2(15),
            cstvnd_id   varchar2(15),
            docmnt_dt   varchar2(10),
            pay_method  varchar2(1),
            amnt        varchar2(15),
            chkbk_id    varchar2(15),
            invdoc_no   varchar2(20),
            unapplied   varchar2(1),
            refund      varchar2(1),
            entity_type varchar2(100),
            entity_id   number
    );
    type ty_tb_payment is
        table of ty_rc_payment;
    type ty_rc_gp_acnts is record (
            batch_id    varchar2(15),
            cstvnd_id   varchar2(15),
            docmnt_dt   varchar2(10),
            rcvpmt_typ  varchar2(1),
            amnt        varchar2(15),--number,
            chckbk_id   varchar2(15),
            docmnt_no   varchar2(20),
            cmnts       varchar2(30),
            invoice_id  number,
            entity_type varchar2(100),
            entity_id   number
    );
    type ty_rec_invoice is record (
            invoice_id      varchar2(17),
            invoice_date    varchar2(10),
            customer_id     varchar2(15),
            customer_name   varchar2(30),
            item_number     varchar2(100),
            price           varchar2(100),
            invoice_line_id number
    );
    type ty_tb_invoice is
        table of ty_rec_invoice;
    type ty_tb_gp_cstmr is
        table of ty_rc_gp_acnts;
    type ty_tb_gp_vndr is
        table of ty_rc_gp_acnts;
    type ty_rec_items is record (
            acnt_typ   varchar2(30),
            amnt       number,
            invoice_id varchar2(17)
    );
    type ty_tb_items is
        table of ty_rec_items;
    type ty_rec_itm_invnt is record (
            itm_nmbr varchar2(30),
            itm_dscr varchar2(100)
    );
    type ty_tb_itm_invnt is
        table of ty_rec_itm_invnt;
    function get_checkbook_id (
        p_prod_type   varchar2,
        p_reason_type varchar2
    ) return varchar2;

    function get_class_id (
        p_prod_type   varchar2,
        p_reason_type varchar2 default null
    ) return varchar2;

    procedure gp_cstmr_adrs (
        x_file_name out varchar2
    );

    procedure gp_vndr_adrs (
        x_file_name out varchar2
    );

    procedure gp_customer_account (
        x_file_name out varchar2
    );

    procedure gp_vendor_account (
        x_file_name out varchar2
    );

    procedure gp_check_payment (
        x_file_name out varchar2
    );--	procedure gp_ap_q(x_file_name out varchar2);
    procedure gp_ach_payment (
        x_file_name out varchar2
    );--	procedure gp_ap_e(x_file_name out varchar2);
    procedure gp_debit_card_payment (
        x_file_name out varchar2
    );--	procedure gp_ap_q(x_file_name out varchar2);
    procedure gp_check_receipt (
        x_file_name out varchar2
    );--	procedure gp_ar_q(x_file_name out varchar2);
    procedure gp_ach_receipt (
        x_file_name out varchar2
    );--	procedure gp_ar_e(x_file_name out varchar2);
    procedure gp_invoices (
        x_file_name out varchar2
    );

    procedure gp_items (
        x_file_name out varchar2
    );

    procedure gp_item_inventory (
        x_file_name out varchar2
    );

    function is_stacked_account (
        p_entrp_id in number
    ) return varchar2;

    procedure gp__manual_post_invoices;

    procedure insert_customer_gt (
        p_customer_id   in varchar2,
        p_customer_name in varchar2,
        p_class_id      in varchar2,
        p_stacked       in varchar2,
        p_account_type  in varchar2,
        p_acc_id        in number,
        p_status        in varchar2,
        p_customer_type in varchar2,
        p_entrp_id      in number,
        p_pers_id       in number
    );

    procedure insert_ap_ar_txn_outbnd (
        p_batch_id    in varchar2,
        p_entity_id   in varchar2,
        p_entity_type in varchar2,
        p_doc_date    in varchar2,
        p_amount      in number,
        p_file_name   in varchar2
    );

    type ty_rec_hsa_fee is record (
            cstmr_id   varchar2(15),
            invoice_id varchar2(17),
            doc_typ    varchar2(1),
            doc_date   varchar2(10),
            due_date   varchar2(10),
            dscrptn    varchar2(30),
            amnt       varchar2(15),
            dist_acnt  varchar2(15),
            dist_type  varchar2(10)
    );
    type ty_tb_hsa_fee is
        table of ty_rec_hsa_fee;
    procedure gp_hsa_fee (
        x_file_name out varchar2
    );

    procedure gp_hsa_interest (
        x_file_name out varchar2
    );

    procedure ftp_gp_files (
        p_file_name in varchar2,
        p_file_dir  in varchar2
    );

    procedure post_customer_files;

    procedure post_invoice_files;

    procedure post_transaction_files;

    procedure ftp_get_gp_files (
        p_file_name in varchar2,
        p_file_dir  in varchar2,
        p_action    in varchar2
    );

    procedure process_error_files;

    procedure update_success_and_error (
        p_table_name  in varchar2,
        p_file_action in varchar2,
        p_file_name   in varchar2
    );

    procedure update_posted_flag (
        p_file_name in varchar2
    );

    function get_check_payment (
        p_date in date
    ) return ty_tb_payment
        pipelined;

    function get_ach_payment (
        p_date in date
    ) return ty_tb_payment
        pipelined;

    function get_ach_receipt (
        p_date in date
    ) return ty_tb_gp_cstmr
        pipelined;

    function get_check_receipt (
        p_date in date
    ) return ty_tb_gp_cstmr
        pipelined;

    function get_debit_card_payment (
        p_date in date
    ) return ty_tb_payment
        pipelined;

    function get_hsa_fee (
        p_date in date
    ) return ty_tb_hsa_fee
        pipelined;

    function get_hsa_interest (
        p_date in date
    ) return ty_tb_hsa_fee
        pipelined;

    function get_invoices (
        p_date in date
    ) return ty_tb_invoice
        pipelined;

end;
/


-- sqlcl_snapshot {"hash":"e66e4efc13f20b7459338ce8caf07b8f3744e840","type":"PACKAGE_SPEC","name":"PC_SAM_GP_INTGRTN","schemaName":"SAMQA","sxml":""}