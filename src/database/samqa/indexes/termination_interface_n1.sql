create index samqa.termination_interface_n1 on
    samqa.termination_interface (
        ssn
    );


-- sqlcl_snapshot {"hash":"c146989d718237682053b88bd4c7240b40c89c60","type":"INDEX","name":"TERMINATION_INTERFACE_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>TERMINATION_INTERFACE_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>TERMINATION_INTERFACE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}