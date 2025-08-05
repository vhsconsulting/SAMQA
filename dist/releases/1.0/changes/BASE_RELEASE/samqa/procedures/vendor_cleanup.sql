-- liquibase formatted sql
-- changeset SAMQA:1754374146750 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\vendor_cleanup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/vendor_cleanup.sql:null:b279e1cc5d0a9ffe62ff441634685b50a0032a93:create

create or replace procedure samqa.vendor_cleanup as

    type vendor_tbl is
        table of varchar2(32000) index by binary_integer;
    l_vendor_id vendor_tbl;
    l_tab       varchar2_4000_tbl := varchar2_4000_tbl();
    l_upd       number;
begin
    select
        vendor_id
    bulk collect
    into l_vendor_id
    from
        (
            select
                wm_concat(vendor_id) vendor_id
            from
                vendors
            where
                acc_num is null
                and pc_person.get_person_name(orig_sys_vendor_ref) is null
                and acc_id is null
                and vendor_acc_num is null
--    AND    VENDOR_ID IN (25231,45141,45837,42138)
            group by
                upper(replace(
                    replace(vendor_name, '.'),
                    ' '
                )),
                upper(replace(
                    replace(address1
                            || ','
                            || address2
                            || ','
                            || city
                            || ','
                            || state
                            || ','
                            || zip, '.'),
                    ' '
                ))
            having
                count(vendor_id) > 1
            union
            select
                wm_concat(vendor_id) vendor_id
            from
                vendors
            where
                vendor_acc_num is not null
            group by
                upper(replace(
                    replace(vendor_name, '.'),
                    ' '
                )),
                upper(replace(
                    replace(address1
                            || ','
                            || address2
                            || ','
                            || city
                            || ','
                            || state
                            || ','
                            || zip, '.'),
                    ' '
                )),
                acc_num,
                vendor_acc_num
            having
                count(vendor_id) > 1
        );

    dbms_output.put_line('count of vendors' || l_vendor_id.count);
    for i in 1..l_vendor_id.count loop
        l_tab := varchar2_4000_tbl();
        l_upd := null;
        l_tab := in_list(
            l_vendor_id(i),
            ','
        );
        dbms_output.put_line('count of vendors' || l_tab.count);
        if l_tab.count > 1 then
            l_upd := l_tab(1);
            for j in 1..l_tab.count loop
                dbms_output.put_line('Vendor to update '
                                     || l_upd
                                     || '  for '
                                     || l_tab(j));

                update payment_register
                set
                    vendor_id = l_upd
                where
                    vendor_id = l_tab(j);

            end loop;

        end if;

    end loop;

end vendor_cleanup;
/

