create index samqa.sys_mtable_0001ad105_ind_5 on
    samqa.sys_export_schema_02 (
        original_object_schema,
        original_object_name,
        partition_name
    );


-- sqlcl_snapshot {"hash":"0ac34830e210074fed8eee1a3de898df0458e1fb","type":"INDEX","name":"SYS_MTABLE_0001AD105_IND_5","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SYS_MTABLE_0001AD105_IND_5</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SYS_EXPORT_SCHEMA_02</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ORIGINAL_OBJECT_SCHEMA</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ORIGINAL_OBJECT_NAME</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PARTITION_NAME</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}