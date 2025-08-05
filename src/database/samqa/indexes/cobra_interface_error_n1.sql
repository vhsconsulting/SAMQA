create index samqa.cobra_interface_error_n1 on
    samqa.cobra_interface_error (
        entity_type
    );


-- sqlcl_snapshot {"hash":"8f5120ceb24a4bc69e6c25f6e22163f3e07b1672","type":"INDEX","name":"COBRA_INTERFACE_ERROR_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>COBRA_INTERFACE_ERROR_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>COBRA_INTERFACE_ERROR</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTITY_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}