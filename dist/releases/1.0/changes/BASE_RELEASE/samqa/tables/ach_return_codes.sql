-- liquibase formatted sql
-- changeset SAMQA:1754374151103 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ach_return_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ach_return_codes.sql:null:7a724a4c1fcf97fcf697ded06d02ee43e2abe43a:create

create table samqa.ach_return_codes (
    return_code      varchar2(3 byte),
    description      varchar2(2000 byte),
    detail           varchar2(2000 byte),
    creation_date    date,
    last_update_date date
);

