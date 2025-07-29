create index samqa.contact_leads_n2 on
    samqa.contact_leads (
        ref_entity_id,
        ref_entity_type
    );


-- sqlcl_snapshot {"hash":"d4b24a64c2d54ab6f95b1f3f073279291ede7a78","type":"INDEX","name":"CONTACT_LEADS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CONTACT_LEADS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CONTACT_LEADS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>REF_ENTITY_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>REF_ENTITY_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}