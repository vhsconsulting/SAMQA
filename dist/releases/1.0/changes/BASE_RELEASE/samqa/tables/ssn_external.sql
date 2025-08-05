-- liquibase formatted sql
-- changeset SAMQA:1754374163358 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ssn_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ssn_external.sql:null:3d10489fd8cbf11c422624a1557719e5bdd3cda1:create

create table samqa.ssn_external (
    ssn          number,
    group_number varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory enroll_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( 'ssn.csv' )
) reject limit 10;

