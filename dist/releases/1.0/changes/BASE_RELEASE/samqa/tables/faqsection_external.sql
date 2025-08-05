-- liquibase formatted sql
-- changeset SAMQA:1754374158421 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\faqsection_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/faqsection_external.sql:null:ea8ba4c8d2400712e5272c54c3a3d509d442237d:create

create table samqa.faqsection_external (
    section_id   number,
    section_name varchar2(3200 byte)
)
organization external ( type oracle_loader
    default directory online_enroll_dir access parameters (
        records delimited by newline
        fields terminated by '~' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( online_enroll_dir : 'faq_section.csv' )
) reject limit unlimited;

