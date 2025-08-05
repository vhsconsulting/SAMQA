-- liquibase formatted sql
-- changeset SAMQA:1754374152950 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\check_result_ack_ext_cnb.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/check_result_ack_ext_cnb.sql:null:6cd97041b438bcbc3a6d576456c29de1625fdf6f:create

create table samqa.check_result_ack_ext_cnb (
    "TransactionLine" varchar2(16 byte),
    cnb_trans_ref     varchar2(16 byte),
    status            varchar2(100 byte),
    reason            varchar2(4000 byte)
)
organization external ( type oracle_loader
    default directory checks_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( checks_dir : 'EASI_Tran.sterlingadmin_uat.202504250001_Acknowledgement.csv' )
) reject limit unlimited;

