-- liquibase formatted sql
-- changeset SAMQA:1754374164281 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\veratad_ofac_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/veratad_ofac_external.sql:null:d90abe4b8b04c6fbbab769889d7ebcb7db38e285:create

create table samqa.veratad_ofac_external (
    first_name        varchar2(80 byte),
    middle_name       varchar2(80 byte),
    last_name         varchar2(80 byte),
    address1          varchar2(80 byte),
    city              varchar2(80 byte),
    state             varchar2(80 byte),
    zip               varchar2(80 byte),
    acc_num           varchar2(80 byte),
    transaction_id    varchar2(80 byte),
    verification_date varchar2(80 byte),
    ofac_code         varchar2(255 byte),
    ofac_text         varchar2(255 byte),
    ofacreference     varchar2(80 byte)
)
organization external ( type oracle_loader
    default directory webservice_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( veratad_inbound : 'VT_6723058_person.txt.out' )
) reject limit unlimited;

