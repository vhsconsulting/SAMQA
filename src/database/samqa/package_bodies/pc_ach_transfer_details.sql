create or replace package body samqa.pc_ach_transfer_details is

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
    ) is
        setup_error exception;
    begin
        x_return_status := 'S';
        select
            decode(p_transaction_id, null, 'Transaction ID cannot be null', 'xx')
            || decode(p_acc_id, null, 'Account Number cannot be null', 'xx')
        into x_error_message
        from
            dual;

        if x_error_message like 'xx%' then
            x_error_message := null;
        else
            raise setup_error;
        end if;
        delete from ach_transfer_details
        where
            transaction_id = p_transaction_id;

        if
            p_ee_fee_amount = 0
            and p_er_fee_amount = 0
            and p_ee_amount = 0
            and p_er_amount = 0
        then
            null;
        else
            insert into ach_transfer_details (
                xfer_detail_id,
                transaction_id,
                group_acc_id,
                acc_id,
                ee_amount,
                er_amount,
                ee_fee_amount,
                er_fee_amount,
                last_updated_by,
                created_by,
                last_update_date,
                creation_date
            ) values ( ach_transfer_details_seq.nextval,
                       p_transaction_id,
                       p_group_acc_id,
                       p_acc_id,
                       p_ee_amount,
                       p_er_amount,
                       p_ee_fee_amount,
                       p_er_fee_amount,
                       p_user_id,
                       p_user_id,
                       sysdate,
                       sysdate );

        end if;

    exception
        when setup_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
    end insert_ach_transfer_details;

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
    ) is
        setup_error exception;
    begin
        x_return_status := 'S';
        if p_transaction_id is null then
            x_error_message := 'Transaction ID cannot be null';
        end if;
        update ach_transfer_details
        set
            ee_amount = p_ee_amount,
            er_amount = p_er_amount,
            ee_fee_amount = p_ee_fee_amount,
            er_fee_amount = p_er_fee_amount,
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
            xfer_detail_id = p_xfer_detail_id;

    exception
        when setup_error then
            x_return_status := 'E';
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
    end update_ach_transfer_details;

    procedure delete_ach_transfer_details (
        p_xfer_detail_id in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    ) is
    begin
        x_return_status := 'S';
        delete from ach_transfer_details
        where
            xfer_detail_id = p_xfer_detail_id;

    exception
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
    end delete_ach_transfer_details;

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
    ) is
    begin
        x_return_status := 'S';
        delete from ach_transfer_details
        where
            transaction_id = p_transaction_id;
 --   pc_log.log_error('MASS_INS_ACH_TRANSFER_DETAILS','account id array '||p_acc_id.count);
        for i in 1..p_acc_id.count loop
--    pc_log.log_error('MASS_INS_ACH_TRANSFER_DETAILS','acc_id '||p_acc_id(i)||'ee amount array '||p_ee_amount(i));
  --  pc_log.log_error('MASS_INS_ACH_TRANSFER_DETAILS','acc_id '||p_acc_id(i)||'er amount array '||p_er_amount(i));

            if
                nvl(
                    p_ee_fee_amount(i),
                    0
                ) = 0
                and nvl(
                    p_er_fee_amount(i),
                    0
                ) = 0
                and nvl(
                    p_ee_amount(i),
                    0
                ) = 0
                and nvl(
                    p_er_amount(i),
                    0
                ) = 0
            then
                null;
            else
                insert into ach_transfer_details (
                    xfer_detail_id,
                    transaction_id,
                    group_acc_id,
                    acc_id,
                    ee_amount,
                    er_amount,
                    ee_fee_amount,
                    er_fee_amount,
                    last_updated_by,
                    created_by,
                    last_update_date,
                    creation_date
                ) values ( ach_transfer_details_seq.nextval,
                           p_transaction_id,
                           p_group_acc_id,
                           p_acc_id(i),
                           nvl(
                               p_ee_amount(i),
                               0
                           ),
                           nvl(
                               p_er_amount(i),
                               0
                           ),
                           nvl(
                               p_ee_fee_amount(i),
                               0
                           ),
                           nvl(
                               p_er_fee_amount(i),
                               0
                           ),
                           p_user_id,
                           p_user_id,
                           sysdate,
                           sysdate ) returning xfer_detail_id into x_xfer_detail_id ( i );
  --  pc_log.log_error('MASS_INS_ACH_TRANSFER_DETAILS','x_xfer_detail_id '||x_xfer_detail_id(i));

            end if;
        end loop;

        for x in (
            select
                sum(nvl(ee_amount, 0) + nvl(er_amount, 0))         amount,
                sum(nvl(ee_fee_amount, 0) + nvl(er_fee_amount, 0)) fee_amount
            from
                ach_transfer_details
            where
                transaction_id = p_transaction_id
        ) loop
            update ach_transfer
            set
                amount = nvl(x.amount, 0),
                fee_amount = nvl(x.fee_amount, 0),
                total_amount = nvl(x.amount, 0) + nvl(x.fee_amount, 0),
                last_update_date = sysdate
            where
                    transaction_id = p_transaction_id
                and status in ( 1, 2 );

        end loop;

    exception
        when others then
            x_return_status := 'U';
            x_error_message := sqlerrm;
    end mass_ins_ach_transfer_details;

end pc_ach_transfer_details;
/


-- sqlcl_snapshot {"hash":"5437f1dc9b8fd88ed44e920cb20c2f5badeb92e4","type":"PACKAGE_BODY","name":"PC_ACH_TRANSFER_DETAILS","schemaName":"SAMQA","sxml":""}