create or replace package samqa.ftp as
-- --------------------------------------------------------------------------
-- Name         : http://www.oracle-base.com/dba/miscellaneous/ftp.pks
-- Author       : DR Timothy S Hall
-- Description  : Basic FTP API. For usage notes see:
--                  http://www.oracle-base.com/articles/misc/FTPFromPLSQL.php
-- Requirements : UTL_TCP
-- Ammedments   :
--   When         Who       What
--   ===========  ========  =================================================
--   14-AUG-2003  Tim Hall  Initial Creation
--   10-MAR-2004  Tim Hall  Add convert_crlf procedure.
--                          Make get_passive function visible.
--                          Added get_direct and put_direct procedures.
--   03-OCT-2006  Tim Hall  Add list, rename, delete, mkdir, rmdir procedures.
--   15-Jan-2008  Tim Hall  login: Include timeout parameter (suggested by Dmitry Bogomolov).
--   12-Jun-2008  Tim Hall  get_reply: Moved to pakage specification.
--   22-Apr-2009  Tim Hall  nlst: Added to return list of file names only (suggested by Julian and John Duncan)
-- --------------------------------------------------------------------------

    type t_string_table is
        table of varchar2(32767);
    function login (
        p_host    in varchar2,
        p_port    in varchar2,
        p_user    in varchar2,
        p_pass    in varchar2,
        p_timeout in number := null
    ) return utl_tcp.connection;

    function get_passive (
        p_conn in out nocopy utl_tcp.connection
    ) return utl_tcp.connection;

    procedure logout (
        p_conn  in out nocopy utl_tcp.connection,
        p_reply in boolean := true
    );

    procedure send_command (
        p_conn    in out nocopy utl_tcp.connection,
        p_command in varchar2,
        p_reply   in boolean := true
    );

    procedure get_reply (
        p_conn in out nocopy utl_tcp.connection
    );

    function get_local_ascii_data (
        p_dir  in varchar2,
        p_file in varchar2
    ) return clob;

    function get_local_binary_data (
        p_dir  in varchar2,
        p_file in varchar2
    ) return blob;

    function get_remote_ascii_data (
        p_conn in out nocopy utl_tcp.connection,
        p_file in varchar2
    ) return clob;

    function get_remote_binary_data (
        p_conn in out nocopy utl_tcp.connection,
        p_file in varchar2
    ) return blob;

    procedure put_local_ascii_data (
        p_data in clob,
        p_dir  in varchar2,
        p_file in varchar2
    );

    procedure put_local_binary_data (
        p_data in blob,
        p_dir  in varchar2,
        p_file in varchar2
    );

    procedure put_remote_ascii_data (
        p_conn in out nocopy utl_tcp.connection,
        p_file in varchar2,
        p_data in clob
    );

    procedure put_remote_binary_data (
        p_conn in out nocopy utl_tcp.connection,
        p_file in varchar2,
        p_data in blob
    );

    procedure get (
        p_conn      in out nocopy utl_tcp.connection,
        p_from_file in varchar2,
        p_to_dir    in varchar2,
        p_to_file   in varchar2
    );

    procedure put (
        p_conn      in out nocopy utl_tcp.connection,
        p_from_dir  in varchar2,
        p_from_file in varchar2,
        p_to_file   in varchar2
    );

    procedure get_direct (
        p_conn      in out nocopy utl_tcp.connection,
        p_from_file in varchar2,
        p_to_dir    in varchar2,
        p_to_file   in varchar2
    );

    procedure put_direct (
        p_conn      in out nocopy utl_tcp.connection,
        p_from_dir  in varchar2,
        p_from_file in varchar2,
        p_to_file   in varchar2
    );

    procedure help (
        p_conn in out nocopy utl_tcp.connection
    );

    procedure ascii (
        p_conn in out nocopy utl_tcp.connection
    );

    procedure binary (
        p_conn in out nocopy utl_tcp.connection
    );

    procedure list (
        p_conn in out nocopy utl_tcp.connection,
        p_dir  in varchar2,
        p_list out t_string_table
    );

    procedure nlst (
        p_conn in out nocopy utl_tcp.connection,
        p_dir  in varchar2,
        p_list out t_string_table
    );

    procedure rename (
        p_conn in out nocopy utl_tcp.connection,
        p_from in varchar2,
        p_to   in varchar2
    );

    procedure delete (
        p_conn in out nocopy utl_tcp.connection,
        p_file in varchar2
    );

    procedure mkdir (
        p_conn in out nocopy utl_tcp.connection,
        p_dir  in varchar2
    );

    procedure rmdir (
        p_conn in out nocopy utl_tcp.connection,
        p_dir  in varchar2
    );

    procedure convert_crlf (
        p_status in boolean
    );

end ftp;
/


-- sqlcl_snapshot {"hash":"55ef6a8e75b8a71c71fd35d35089c1703c7e88ae","type":"PACKAGE_SPEC","name":"FTP","schemaName":"SAMQA","sxml":""}