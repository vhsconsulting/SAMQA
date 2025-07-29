create index samqa.sys_mtable_0001ad105_ind_3 on
    samqa.sys_export_schema_02 (
        object_schema,
        object_name,
        object_type,
        partition_name,
        subpartition_name
    );


-- sqlcl_snapshot {"hash":"b0ab0a75e10cb89c4fb3a6fb966068c4a846e406","type":"INDEX","name":"SYS_MTABLE_0001AD105_IND_3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SYS_MTABLE_0001AD105_IND_3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SYS_EXPORT_SCHEMA_02</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>OBJECT_SCHEMA</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>OBJECT_NAME</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>OBJECT_TYPE</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PARTITION_NAME</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>SUBPARTITION_NAME</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}