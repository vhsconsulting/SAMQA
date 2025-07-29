create or replace package samqa.pc_bankserv_pkg is
    procedure pc_bankserv_txn (
        p_batch_number in number,
        p_user_id      in number
    );

    procedure upload_bankserv_data (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

    procedure validate_data (
        p_txn_id in number,
        p_status out varchar2
    );

end pc_bankserv_pkg;
/


-- sqlcl_snapshot {"hash":"4f994dee5d91ea8d2f0cbede8ed238536e89811b","type":"PACKAGE_SPEC","name":"PC_BANKSERV_PKG","schemaName":"SAMQA","sxml":""}