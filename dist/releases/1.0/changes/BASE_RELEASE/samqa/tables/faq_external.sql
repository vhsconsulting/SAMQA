-- liquibase formatted sql
-- changeset SAMQA:1754374158379 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\faq_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/faq_external.sql:null:fd5b580e1dbe010d3e18c7d0ee5d87d20e82b693:create

create table samqa.faq_external (
    faq_id     number,
    section    number,
    faq_number number,
    question   varchar2(255 byte),
    answer     varchar2(3200 byte),
    visible    varchar2(1 byte)
)
organization external ( type oracle_loader
    default directory online_enroll_dir access parameters (
        records delimited by newline
        fields terminated by '~' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( online_enroll_dir : 'faq.csv' )
) reject limit unlimited;

