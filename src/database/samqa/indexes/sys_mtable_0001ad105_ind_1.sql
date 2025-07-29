create unique index samqa.sys_mtable_0001ad105_ind_1 on
    samqa.sys_export_schema_02 (
        process_order,
        duplicate
    );


-- sqlcl_snapshot {"hash":"386995d6b76c9b504b9ad973809e3928a5539f73","type":"INDEX","name":"SYS_MTABLE_0001AD105_IND_1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SYS_MTABLE_0001AD105_IND_1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SYS_EXPORT_SCHEMA_02</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PROCESS_ORDER</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>DUPLICATE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}