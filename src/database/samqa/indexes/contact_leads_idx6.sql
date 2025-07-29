create index samqa.contact_leads_idx6 on
    samqa.contact_leads (
        send_invoice
    );


-- sqlcl_snapshot {"hash":"ae87c59cd01e65fc7f0f9dab54540436027fa0e3","type":"INDEX","name":"CONTACT_LEADS_IDX6","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CONTACT_LEADS_IDX6</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CONTACT_LEADS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SEND_INVOICE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}