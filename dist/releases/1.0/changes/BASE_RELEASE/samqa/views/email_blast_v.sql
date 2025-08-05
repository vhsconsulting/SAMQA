-- liquibase formatted sql
-- changeset SAMQA:1754374171897 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\email_blast_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/email_blast_v.sql:null:ba21dd1511e0a226a17ec533c5e5f408735ccf4e:create

create or replace force editionable view samqa.email_blast_v (
    employee_id,
    card_number,
    name,
    status,
    dependant,
    employer_name,
    email
) as
    select
        a.acc_num                     employee_id,
        'XXXX-XXXX-XXXX-'
        || substr(card_number, 13, 4) card_number,
        c.first_name
        || ' '
        || c.last_name                name,
        decode(status_code, 1, 'New', 2, 'Active',
               3, 'Suspended')        status,
        null                          dependant,
        (
            select
                name
            from
                enterprise
            where
                entrp_id = c.entrp_id
        )                             employer_name,
        c.email
    from
        metavante_cards a,
        account         b,
        person          c
    where
            a.acc_num = b.acc_num
        and a.status_code in ( 1, 2, 3 )
        and b.account_status <> 4
        and b.account_type = 'HSA'
        and c.pers_id = b.pers_id
        and a.dependant_id is null
    union all
    select
        employee_id,
        'XXXX-XXXX-XXXX-'
        || substr(card_number, 13, 4) card_number,
        name,
        status,
        dependant,
        employer_name,
        email
    from
        (
            select
                a.acc_num                                        employee_id,
                card_number,
                c.first_name
                || ' '
                || c.last_name                                   name,
                decode(status_code, 1, 'New', 2, 'Active',
                       3, 'Suspended')                           status,
                decode(dependant_id, null, '', 'Dependant Card') dependant,
                (
                    select
                        name
                    from
                        enterprise aa,
                        person     k
                    where
                            aa.entrp_id = k.entrp_id
                        and k.pers_id = b.pers_id
                )                                                employer_name,
                a.status_code,
                case
                    when count(card_number)
                             over(partition by a.acc_num, dependant_id) > 1
                         and a.status_code = 1 then
                        'NO'
                    else
                        'YES'
                end                                              no_of_cards,
                d.email
            from
                metavante_cards a,
                account         b,
                person          c,
                person          d
            where
                    a.acc_num = b.acc_num
                and c.pers_main = d.pers_id
                and b.pers_id = d.pers_id
                and b.account_type = 'HSA'
                and a.status_code in ( 1, 2, 3 )
                and b.account_status <> 4
                and a.dependant_id = c.pers_id
                and a.dependant_id is not null
        )
    where
        no_of_cards = 'YES';

