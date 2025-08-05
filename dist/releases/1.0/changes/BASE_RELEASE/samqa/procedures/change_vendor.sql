-- liquibase formatted sql
-- changeset SAMQA:1754374142658 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\change_vendor.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/change_vendor.sql:null:6c522afc3d0101100b42cbf8f76337d260390806:create

create or replace procedure samqa.change_vendor as

    l_vendor_id   number;
    l_acc_num     varchar2(255);
    l_vendor_name varchar2(3200);
    l_address1    varchar2(3200);
    l_change      varchar2(255);
begin
    for x in (
        select
            *
        from
            (
                select
                    a.provider_name,
                    replace(
                        replace(b.vendor_name, '.'),
                        ' '
                    )                vendor_name,
                    a.acc_id,
                    a.acc_num,
                    b.vendor_id,
                    a.claim_id,
                    replace(
                        replace(address1, '.'),
                        ' '
                    )                address1,
                    b.city,
                    b.state,
                    b.zip,
                    count(distinct a.vendor_id)
                    over(partition by replace(
                        replace(b.vendor_name, '.'),
                        ' '
                    ),
                          replace(
                        replace(address1, '.'),
                        ' '
                    ),
                          a.acc_id,
                          a.acc_num) cnt
                from
                    payment_register a,
                    vendors          b
                where
                    claim_type in ( 'PROVIDER_ONLINE', 'PROVIDER', 'PROVIDER_FROM_BPS' )
                    and a.vendor_id = b.vendor_id
            )
        where
            cnt > 1
    ) loop
        if
            l_acc_num = x.acc_num
            and l_vendor_name = x.vendor_name
            and l_address1 = x.address1
        then
            update payment_register
            set
                vendor_id = l_vendor_id
            where
                claim_id = x.claim_id;

        else
            l_vendor_id := x.vendor_id;
        end if;

        l_acc_num := x.acc_num;
        l_vendor_name := x.vendor_name;
        l_address1 := x.address1;
    end loop;
end;
/

