create index samqa.ar_invoice_contacts_n2 on
    samqa.ar_invoice_contacts (
        contact_id
    );


-- sqlcl_snapshot {"hash":"4cbe7ec5503f7bbd1af3ad6f6f42606ee06afd6d","type":"INDEX","name":"AR_INVOICE_CONTACTS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_INVOICE_CONTACTS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_INVOICE_CONTACTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CONTACT_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}