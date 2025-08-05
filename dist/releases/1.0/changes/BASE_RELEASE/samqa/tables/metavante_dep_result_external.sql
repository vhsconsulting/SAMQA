-- liquibase formatted sql
-- changeset SAMQA:1754374160638 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\metavante_dep_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/metavante_dep_result_external.sql:null:6f7f2a794b7ba0eb2bace7cd5afd584709a94799:create

create table samqa.metavante_dep_result_external (
    record_id    varchar2(255 byte),
    employer_id  varchar2(255 byte),
    employee_id  varchar2(255 byte),
    dependant_id varchar2(255 byte),
    attribute1   varchar2(255 byte),
    attribute2   varchar2(255 byte),
    attribute3   varchar2(255 byte),
    attribute4   varchar2(255 byte),
    attribute5   varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory debit_card_dir access parameters (
        records delimited by newline
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( debit_card_dir : 'MB_6800036_hra_dep_create.res' )
) reject limit unlimited;

