-- liquibase formatted sql
-- changeset SAMQA:1754374155588 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\del_income_cobra.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/del_income_cobra.sql:null:fcd0606dbec0d85179ea13990f82ed1d15547a6e:create

create table samqa.del_income_cobra (
    acc_id        number(9, 0) not null enable,
    no_of_records number
);

