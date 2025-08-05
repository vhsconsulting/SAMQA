-- liquibase formatted sql
-- changeset SAMQA:1754374163674 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\temp_gp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/temp_gp.sql:null:5379ffcfd8f9e33f1d66d2416f2a3c4050136ef6:create

create table samqa.temp_gp (
    acc_num varchar2(30 byte),
    balance number
);

