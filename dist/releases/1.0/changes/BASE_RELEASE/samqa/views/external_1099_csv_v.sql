-- liquibase formatted sql
-- changeset SAMQA:1754374173291 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\external_1099_csv_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/external_1099_csv_v.sql:null:873f4298743745ecbdc54089be4a8c66c1284c7b:create

create or replace force editionable view samqa.external_1099_csv_v (
    output,
    begin_date,
    end_date
) as
    select
        acc_num
        || ',"'
        || b.first_name
        || ' '
        || b.middle_name
        || ' '
        || b.last_name
        || '","'
        || b.address
        || '","'
        || b.city
        || '","'
        || b.state
        || '","'
        || b.zip
        || '","'
        || b.ssn
        || '","'
        || a.gross_dist
        || '","'
        || a.corrected_flag
        || '","'
        || a.override_flag
        || '","'
        || a.corrected_by
        || '","'
        || a.overridden_by
        || '",'
        || pc_users.is_active_user(
            replace(b.ssn, '-'),
            'S'
        ) output,
        a.begin_date,
        a.end_date
    from
        tax_forms a,
        person    b
    where
            a.pers_id = b.pers_id
        and a.tax_doc_type = '1099'
        and a.tax_form_id in (
            select
                max(c.tax_form_id)
            from
                tax_forms c
            where
                    c.begin_date = a.begin_date
                and c.end_date = a.end_date
                and a.acc_id = c.acc_id
                and a.tax_doc_type = c.tax_doc_type
        );

