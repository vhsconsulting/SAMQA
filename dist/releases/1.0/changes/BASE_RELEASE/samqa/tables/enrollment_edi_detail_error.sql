-- liquibase formatted sql
-- changeset SAMQA:1754374156787 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\enrollment_edi_detail_error.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/enrollment_edi_detail_error.sql:null:06de2e96cc6e421cd0ba8cb1652d06db67290101:create

create table samqa.enrollment_edi_detail_error (
    detail_id              number,
    segment_element_ind    varchar2(1 byte),
    element_position       varchar2(5 byte),
    element_ref_number     varchar2(5 byte),
    bad_element_data       varchar2(80 byte),
    segment_cd             varchar2(3 byte),
    segment_position_count number(5, 0),
    loop_id                varchar2(5 byte),
    syntax_err_cd          varchar2(2 byte),
    error_desc             varchar2(100 byte),
    creation_date          date default sysdate
);

