-- liquibase formatted sql
-- changeset SAMQA:1754374160573 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\metavante_authorizations.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/metavante_authorizations.sql:null:e8faf8e230ad529b8f98a0799e7dfb68779977f9:create

create table samqa.metavante_authorizations (
    authorization_id   number,
    acc_num            varchar2(30 byte),
    pers_id            number,
    merchant_name      varchar2(255 byte),
    transaction_amount number,
    transaction_date   date,
    mcc_code           varchar2(30 byte),
    approval_code      varchar2(255 byte),
    creation_date      date,
    last_update_date   date,
    plan_type          varchar2(30 byte)
);

create unique index samqa.metavante_authorizations_pk on
    samqa.metavante_authorizations (
        authorization_id,
        approval_code
    );

alter table samqa.metavante_authorizations
    add constraint metavante_authorizations_pk
        primary key ( authorization_id,
                      approval_code )
            using index samqa.metavante_authorizations_pk enable;

