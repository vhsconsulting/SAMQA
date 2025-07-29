create or replace type samqa.samclob as object (
        vclob    clob,
        filename varchar2(256),
        mimetype varchar2(256)
);
/


-- sqlcl_snapshot {"hash":"2bf98ac9f3f8696a6a95ba602022d840f20b0813","type":"TYPE_SPEC","name":"SAMCLOB","schemaName":"SAMQA","sxml":""}