-- liquibase formatted sql
-- changeset SAMQA:1754374166317 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\listfile_typ.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/listfile_typ.sql:null:c6ca517addd024cdf0e942d483896238bd0a3c0a:create

create or replace type samqa.listfile_typ as object (
        fpermission varchar2(500),
        flink       varchar2(2),
        fowner      varchar2(500),
        fgroup      varchar2(500),
        fsize       varchar2(500),
        fdate       varchar2(20),
        ftime       varchar2(20),
        fname       varchar2(500)
);
/

