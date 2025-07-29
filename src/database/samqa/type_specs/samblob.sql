create or replace type samqa.samblob as object (
        vblob    blob,
        filename varchar2(256),
        mimetype varchar2(256)
);
/


-- sqlcl_snapshot {"hash":"846ca92aefdc0c877fb9e1878c3965a274a2dfa7","type":"TYPE_SPEC","name":"SAMBLOB","schemaName":"SAMQA","sxml":""}