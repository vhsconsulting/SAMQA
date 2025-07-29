create or replace force editionable view samqa.external_1099_v (
    output,
    begin_date,
    end_date
) as
    select
        '10511'
        || chr(9)
        || to_char(trunc(sysdate, 'YYYY') - 1,
                   'YYYY')
        || chr(9)
        || rpad(b.ssn, 11, ' ')
        || chr(9)
        || rpad(b.first_name, 40, ' ')
        || chr(9)
        || rpad(b.last_name, 40, ' ')
        || chr(9)
        || rpad(b.address, 40, ' ')
        || chr(9)
        || rpad(b.city, 40, ' ')
        || chr(9)
        || rpad(b.state, 2, ' ')
        || chr(9)
        || rpad(b.zip, 5, ' ')
        || chr(9)
        || rpad(a.acc_num, 20, ' ')
        || chr(9)
        || lpad(a.gross_dist, 10, 0)
        || chr(9)
        || rpad(0, 10, 0)
        || chr(9)
        || '01'
        || chr(9)
        || rpad(0, 10, 0)
        || chr(9)
        || 'X'
        || chr(9)
        || ' '
        || chr(9)
        || ' '
        || chr(9)
        || to_char(sysdate, 'YYYYMMDD')
        || chr(9)
        || '1099-SA   '
        || chr(9)
        || '84-1637046' output,
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


-- sqlcl_snapshot {"hash":"deb60c08a92ab03fbd4fe7812cf0add922147ecc","type":"VIEW","name":"EXTERNAL_1099_V","schemaName":"SAMQA","sxml":""}