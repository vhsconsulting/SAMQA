create unique index samqa.vendors_u1 on
    samqa.vendors (
        vendor_id
    );


-- sqlcl_snapshot {"hash":"fa364d427a5048fe775d8b3cad64c03a0c268fd4","type":"INDEX","name":"VENDORS_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <UNIQUE></UNIQUE>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>VENDORS_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>VENDORS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>VENDOR_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}