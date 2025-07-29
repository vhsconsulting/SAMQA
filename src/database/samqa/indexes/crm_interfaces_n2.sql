create index samqa.crm_interfaces_n2 on
    samqa.crm_interfaces (
        entity_id
    );


-- sqlcl_snapshot {"hash":"8267b29d2aa1f9e4e27d6527579894432ceffa32","type":"INDEX","name":"CRM_INTERFACES_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CRM_INTERFACES_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CRM_INTERFACES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTITY_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}