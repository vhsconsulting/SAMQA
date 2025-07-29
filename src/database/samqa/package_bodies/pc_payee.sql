create or replace package body samqa.pc_payee as

    procedure add_payee (
        p_payee_name          in varchar2,
        p_payee_acc_num       in varchar2,
        p_address             in varchar2,
        p_city                in varchar2,
        p_state               in varchar2,
        p_zipcode             in varchar2,
        p_acc_num             in varchar2,
        p_user_id             in varchar2,
        p_orig_sys_vendor_ref in varchar2 default null,
        p_acc_id              in number,
        p_payee_type          in varchar2,
        p_payee_tax_id        in varchar2,
        p_payee_nick_name     in varchar2,
        x_vendor_id           out number,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    ) is
        l_vendor_id number;
        l_acc_id    number;
    begin
        x_return_status := 'S';
        pc_log.log_error('ADD_PAYEE', 'START OF ADD_PAYEE');
        pc_log.log_error('P_PAYEE_ACC_NUM', p_payee_acc_num);
        pc_log.log_error('P_ADDRESS', p_address);
        pc_log.log_error('P_CITY', p_city);
        pc_log.log_error('P_STATE', p_state);
        pc_log.log_error('P_PAYEE_NICK_NAME', p_payee_nick_name);
        insert into vendors (
            vendor_id,
            orig_sys_vendor_ref,
            vendor_name,
            address1,
            address2,
            city,
            state,
            zip,
            expense_account,
            acc_num,
            vendor_in_peachtree,
            vendor_acc_num,
            acc_id,
            vendor_tax_id,
            vendor_type,
            vendor_status,
            payee_nick_name,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( vendor_seq.nextval,
                   nvl(p_orig_sys_vendor_ref, p_acc_num),
                   p_payee_name -- Payee Name
                   ,
                   p_address        -- Payee Address
                   ,
                   null,
                   p_city             -- Payee City
                   ,
                   p_state            -- Payee State
                   ,
                   p_zipcode		  -- Payee Zip
                   ,
                   2400		  -- Expense Account
                   ,
                   nvl(p_acc_num,
                       pc_account.get_acc_num_from_acc_id(p_acc_id)),
                   'N',
                   p_payee_acc_num -- Payee Account Number
                   ,
                   p_acc_id,
                   p_payee_tax_id,
                   p_payee_type,
                   'A',
                   p_payee_nick_name,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id ) returning vendor_id into x_vendor_id;

        pc_log.log_error('ADD_PAYEE', 'x_vendor_id ' || x_vendor_id);
    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end add_payee;

    procedure update_payee (
        p_payee_name    in varchar2,
        p_payee_acc_num in varchar2,
        p_address       in varchar2,
        p_city          in varchar2,
        p_state         in varchar2,
        p_zipcode       in varchar2,
        p_user_id       in varchar2,
        p_payee_tax_id  in varchar2,
        p_vendor_id     in number
--, P_PAYEE_NICK_NAME    IN VARCHAR2
        ,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_vendor_id number;
    begin
        x_return_status := 'S';
        update vendors
        set
            vendor_name = decode(vendor_name, p_payee_name, vendor_name, p_payee_name),
            address1 = decode(address1, p_address, address1, p_address),
            city = decode(city, p_city, city, p_city),
            state = decode(state, p_state, state, p_state),
            zip = decode(zip, p_zipcode, zip, p_zipcode),
            vendor_acc_num = decode(vendor_acc_num, p_payee_acc_num, vendor_acc_num, p_payee_acc_num),
            vendor_tax_id = decode(vendor_tax_id, p_payee_tax_id, vendor_tax_id, p_payee_tax_id)
--	,PAYEE_NICK_NAME= DECODE(PAYEE_NICK_NAME,P_PAYEE_NICK_NAME,PAYEE_NICK_NAME,P_PAYEE_NICK_NAME)
            ,
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            vendor_id = p_vendor_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end update_payee;

    procedure delete_payee (
        p_vendor_id     in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
        update vendors
        set
            vendor_status = 'I',
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            vendor_id = p_vendor_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end delete_payee;

    function get_payee (
        p_acc_id       in number,
        p_service_type in varchar2,
        p_address      in varchar2,
        p_city         in varchar2,
        p_state        in varchar2,
        p_zip          in varchar2
    ) return number is
        l_vendor_id number;
    begin
        for x in (
            select
                vendor_id
            from
                vendors
            where
                    acc_id = p_acc_id
                and vendor_type = p_service_type
                and address1
                    || ' '
                    || address2 = p_address
                and city = p_city
                and state = p_state
                and zip = p_zip
        ) loop
            l_vendor_id := x.vendor_id;
        end loop;

        return l_vendor_id;
    end get_payee;

    function get_payee_name (
        p_vendor_id in number
    ) return varchar2 is
        l_payee_name varchar2(3200);
    begin
        for x in (
            select
                vendor_name
            from
                vendors
            where
                vendor_id = p_vendor_id
        ) loop
            l_payee_name := x.vendor_name;
        end loop;

        return l_payee_name;
    end get_payee_name;

    procedure add_eob_provider (
        p_payee_name      in varchar2,
        p_address1        in varchar2,
        p_address2        in varchar2,
        p_city            in varchar2,
        p_state           in varchar2,
        p_zipcode         in varchar2,
        p_user_id         in varchar2,
        p_payee_npi       in varchar2 default null,
        p_acc_id          in number,
        p_payee_tax_id    in varchar2,
        p_provider_id     in number,
        p_payee_nick_name in varchar2,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is
        l_vendor_id number;
    begin
        x_return_status := 'S';
        pc_log.log_error('add_eob_provider', 'START OF add_eob_provider');
        insert into eob_provider (
            eob_provider_id,
            provider_name,
            provider_npi,
            address1,
            address2,
            city,
            state,
            zip,
            acc_id,
            tax_id,
            payee_nick_name,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                p_provider_id,
                p_payee_name -- Payee Name
                ,
                p_payee_npi,
                p_address1        -- Payee Address
                ,
                p_address2,
                p_city             -- Payee City
                ,
                p_state            -- Payee State
                ,
                p_zipcode		  -- Payee Zip
                ,
                p_acc_id,
                p_payee_tax_id,
                p_payee_nick_name,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                dual
            where
                not exists (
                    select
                        *
                    from
                        eob_provider
                    where
                        eob_provider_id = p_provider_id
                );

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end add_eob_provider;

end pc_payee;
/


-- sqlcl_snapshot {"hash":"3e6dc4fae922cb853dad1103cdefcfa7cd5c5881","type":"PACKAGE_BODY","name":"PC_PAYEE","schemaName":"SAMQA","sxml":""}