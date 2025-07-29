alter table samqa.eob_detail
    add
        foreign key ( eob_id )
            references samqa.eob_header ( eob_id )
        enable;


-- sqlcl_snapshot {"hash":"71f6c83cfd83fdd2683092882795eb84d7ac24f5","type":"REF_CONSTRAINT","name":"EOB_DETAIL.SAMQA.EOB_HEADER","schemaName":"SAMQA","sxml":""}