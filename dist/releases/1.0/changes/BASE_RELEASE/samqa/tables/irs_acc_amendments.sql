-- liquibase formatted sql
-- changeset SAMQA:1754374159818 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\irs_acc_amendments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/irs_acc_amendments.sql:null:8c4fb219addc76fd20eaebf3d4a05bfaf593fcb0:create

create table samqa.irs_acc_amendments (
    acc_id            number,
    accept_flag       varchar2(1 byte),
    creation_date     date default sysdate,
    created_by        number,
    irs_id            number,
    last_updated_by   number,
    last_updated_date date default sysdate,
    plan_type         varchar2(20 byte)
);

