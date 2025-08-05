create unique index samqa.sys_mtable_00019f226_ind_1 on
    samqa.sys_export_schema_01 (
        process_order,
        duplicate
    );


-- sqlcl_snapshot {"hash":"883071e2971286ce4e585ade45885c238ae3c24d","type":"INDEX","name":"SYS_MTABLE_00019F226_IND_1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SYS_MTABLE_00019F226_IND_1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SYS_EXPORT_SCHEMA_01</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PROCESS_ORDER</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DUPLICATE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}