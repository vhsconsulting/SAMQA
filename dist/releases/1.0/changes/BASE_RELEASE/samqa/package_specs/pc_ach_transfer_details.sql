-- liquibase formatted sql
-- changeset SAMQA:1754374134005 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_ach_transfer_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_ach_transfer_details.sql:null:b9f4cbdf7cc1ff08137d279c8333f22a52c62d12:create

create or replace package samqa.pc_ach_transfer_details is
    type number_tbl is
        table of varchar(20) index by binary_integer;
    procedure insert_ach_transfer_details (
        p_transaction_id in number,
        p_group_acc_id   in number,
        p_acc_id         in number,
        p_ee_amount      in number,
        p_er_amount      in number,
        p_ee_fee_amount  in number,
        p_er_fee_amount  in number,
        p_user_id        in number,
        x_xfer_detail_id out number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

    procedure mass_ins_ach_transfer_details (
        p_transaction_id in number,
        p_group_acc_id   in number,
        p_acc_id         in number_tbl,
        p_ee_amount      in number_tbl,
        p_er_amount      in number_tbl,
        p_ee_fee_amount  in number_tbl,
        p_er_fee_amount  in number_tbl,
        p_user_id        in number,
        x_xfer_detail_id out number_tbl,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

    procedure update_ach_transfer_details (
        p_xfer_detail_id in number,
        p_transaction_id in number,
        p_ee_amount      in number,
        p_er_amount      in number default null,
        p_ee_fee_amount  in number default null,
        p_er_fee_amount  in number default null,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

    procedure delete_ach_transfer_details (
        p_xfer_detail_id in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

end pc_ach_transfer_details;
/

