create index samqa.vendors_n2 on
    samqa.vendors (
        orig_sys_vendor_ref
    );


-- sqlcl_snapshot {"hash":"56f23289c7d86cf3c73b0e2d47da7bff2c3fe405","type":"INDEX","name":"VENDORS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>VENDORS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>VENDORS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ORIG_SYS_VENDOR_REF</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}