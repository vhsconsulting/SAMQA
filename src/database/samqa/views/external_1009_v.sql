create or replace force editionable view samqa.external_1009_v (
    output
) as
    select
        'STERL'
        || chr(9)
        || to_char(trunc(sysdate, 'YYYY') - 1,
                   'YYYY')
        || chr(9)
        || lpad(p.ssn, 11, ' ')
        || chr(9)
        || lpad(p.first_name, 40, ' ')
        || chr(9)
        || lpad(p.last_name, 40, ' ')
        || chr(9)
        || lpad(p.address, 40, ' ')
        || chr(9)
        || lpad(p.city, 40, ' ')
        || chr(9)
        || lpad(p.state, 2, ' ')
        || chr(9)
        || lpad(p.zip, 5, ' ')
        || chr(9)
        || lpad(c.acc_num, 20, ' ')
        || chr(9)
        || lpad(
            sum(pay.amount),
            10,
            0
        )
        || chr(9)
        || lpad(0, 10, 0)
        || chr(9)
        || '01'
        || chr(9)
        || lpad(0, 10, 0)
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
        || lpad(0, 10, 0) output
    from
        payment pay,
        person  p,
        account c
    where
            pay.acc_id = c.acc_id
        and p.pers_id = c.pers_id
        and pay.reason_code in ( 11, 12, 13, 19 )
        and to_char(pay.pay_date, 'YYYY') = to_char(trunc(sysdate, 'YYYY') - 1,
                                                    'YYYY')
    group by
        c.acc_id,
        c.acc_num,
        p.pers_id,
        p.pers_main,
        p.first_name,
        p.middle_name,
        p.last_name,
        p.address,
        p.city,
        p.state,
        p.zip,
        p.county,
        p.ssn
    having
        sum(pay.amount) > 0
    order by
        p.pers_id;


-- sqlcl_snapshot {"hash":"2a2ff44100ccd346b1b2cb81b8c6c8f4d9df8899","type":"VIEW","name":"EXTERNAL_1009_V","schemaName":"SAMQA","sxml":""}