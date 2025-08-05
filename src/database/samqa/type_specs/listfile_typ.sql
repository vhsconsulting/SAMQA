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


-- sqlcl_snapshot {"hash":"c6ca517addd024cdf0e942d483896238bd0a3c0a","type":"TYPE_SPEC","name":"LISTFILE_TYP","schemaName":"SAMQA","sxml":""}