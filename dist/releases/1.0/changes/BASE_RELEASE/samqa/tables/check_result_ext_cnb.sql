-- liquibase formatted sql
-- changeset SAMQA:1754374152965 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\check_result_ext_cnb.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/check_result_ext_cnb.sql:null:46fc31585edf301c38347497a2c8bf2241cbcd1c:create

create table samqa.check_result_ext_cnb (
    cnb_trans_ref   varchar2(16 byte),
    status_code     varchar2(4 byte),
    status_name     varchar2(4000 byte),
    status_desc     varchar2(4000 byte),
    confirmation_id varchar2(400 byte)
)
organization external ( type oracle_loader
    default directory checks_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( checks_dir : 'EASI_Status.sterlingadmin.202504251828.csv' )
) reject limit unlimited;

