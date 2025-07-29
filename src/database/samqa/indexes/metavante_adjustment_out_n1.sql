create index samqa.metavante_adjustment_out_n1 on
    samqa.metavante_adjustment_outbound ( to_char(change_num) );


-- sqlcl_snapshot {"hash":"a803a34b31e48935cf692b8af09ad3c5119b033e","type":"INDEX","name":"METAVANTE_ADJUSTMENT_OUT_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_ADJUSTMENT_OUT_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_ADJUSTMENT_OUTBOUND</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TO_CHAR(\"CHANGE_NUM\")</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}