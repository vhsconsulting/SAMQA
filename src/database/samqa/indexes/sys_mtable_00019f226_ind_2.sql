create index samqa.sys_mtable_00019f226_ind_2 on
    samqa.sys_export_schema_01 (
        object_schema,
        original_object_name,
        object_type
    );


-- sqlcl_snapshot {"hash":"8e7beb71b8430255cb9bbb6adf64984a2532ae67","type":"INDEX","name":"SYS_MTABLE_00019F226_IND_2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SYS_MTABLE_00019F226_IND_2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SYS_EXPORT_SCHEMA_01</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>OBJECT_SCHEMA</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ORIGINAL_OBJECT_NAME</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>OBJECT_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}