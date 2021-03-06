
/*
 * TeeJee.FileSystem.vala
 *
 * Copyright 2016 Tony George <teejeetech@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 *
 */
 
namespace TeeJee.FileSystem{

	/* Convenience functions for handling files and directories */

	using TeeJee.Logging;
	using TeeJee.ProcessHelper;
	using TeeJee.Misc;

	public const int64 KB = 1000;
	public const int64 MB = 1000 * KB;
	public const int64 GB = 1000 * MB;
	public const int64 TB = 1000 * GB;
	public const int64 KiB = 1024;
	public const int64 MiB = 1024 * KiB;
	public const int64 GiB = 1024 * MiB;
	public const int64 TiB = 1024 * GiB;
	
	// path helpers ----------------------------
	
	public string file_parent(string file_path){
		return File.new_for_path(file_path).get_parent().get_path();
	}

	public string file_basename(string file_path){
		return File.new_for_path(file_path).get_basename();
	}

	public string file_get_title(string file_path){
		
		string file_name = File.new_for_path(file_path).get_basename();

		int end = file_name.length - file_get_extension(file_path).length;
		return file_name[0:end];
	}

	public string file_get_extension(string file_path){
		
		string file_name = File.new_for_path(file_path).get_basename();

		string[] parts = file_name.split(".");

		if (parts.length == 1){
			// no extension
			return "";
		}
		
		if (parts.length > 2){
			
			string ext1 = parts[parts.length-2];
			string ext2 = parts[parts.length-1];
			
			if ((ext1.length <= 4) && (ext2.length <= 4) && (ext1 == "tar")){
				// 2-part extension
				return ".%s.%s".printf(parts[parts.length-2], parts[parts.length-1]);
			}
		}
		
		if (parts.length > 1){
			return ".%s".printf(parts[parts.length - 1]);
		}

		return "";
	}

	public string file_generate_unique_name(string file_path){
		
		string title = file_get_title(file_path);
		string extension = file_get_extension(file_path);
		string location = file_parent(file_path);
		
		string outpath = file_path;
		
		int index = 1;
		while (file_exists(outpath)){
			string new_name = "%s%s%s".printf(title, " (%d)".printf(index++), extension);
			outpath = path_combine(location, new_name);
		}

		return outpath;
	}
	
	public string path_combine(string path1, string path2){
		return GLib.Path.build_path("/", path1, path2);
	}

	public string remove_trailing_slash(string path){
		if (path.has_suffix("/")){
			return path[0:path.length - 1];
		}
		else{
			return path;
		}
	}
	
	// file helpers -----------------------------

	public bool file_exists(string item_path){
		
		/* check if item exists on disk*/

		var item = File.parse_name(item_path);
		return item.query_exists();
	}
	
	public bool file_is_dir(string file_path){

		try {
			var file = File.new_for_path (file_path);
			
			if (file.query_exists()) {

				var info = file.query_info("%s".printf(FileAttribute.STANDARD_TYPE),0); // follow symlinks

				var file_type = info.get_file_type();

				return (file_type == FileType.DIRECTORY);
			}
		}
		catch (Error e) {
	        log_error (e.message);
	    }
	    
		return false;
	}

	public bool file_is_regular(string file_path){

		try {
			var file = File.new_for_path (file_path);
			
			if (file.query_exists()) {

				var info = file.query_info("%s".printf(FileAttribute.STANDARD_TYPE),0); // follow symlinks

				var file_type = info.get_file_type();

				return (file_type == FileType.REGULAR);
			}
		}
		catch (Error e) {
	        log_error (e.message);
	    }
	    
		return false;
	}

	public bool file_is_special(string file_path){

		try {
			var file = File.new_for_path (file_path);
			
			if (file.query_exists()) {

				var info = file.query_info("%s".printf(FileAttribute.STANDARD_TYPE), 0); // follow symlinks

				var file_type = info.get_file_type();

				return (file_type != FileType.REGULAR) && (file_type != FileType.DIRECTORY);
			}
		}
		catch (Error e) {
	        log_error (e.message);
	    }
	    
		return false;
	}

	public bool file_is_symlink(string file_path){

		try {
			var file = File.new_for_path (file_path);
			
			if (file.query_exists()) {

				var info = file.query_info("%s".printf(FileAttribute.STANDARD_TYPE), FileQueryInfoFlags.NOFOLLOW_SYMLINKS); // don't follow symlinks

				var file_type = info.get_file_type();

				return (file_type == FileType.SYMBOLIC_LINK);
			}
		}
		catch (Error e) {
	        log_error (e.message);
	    }
	    
		return false;
	}

	public bool file_delete(string file_path){

		/* Check and delete file */

		try {
			var file = File.new_for_path (file_path);
			if (file.query_exists ()) {
				file.delete ();
			}
			return true;
		} catch (Error e) {
	        log_error (e.message);
	        log_error(_("Failed to delete file") + ": %s".printf(file_path));
	        return false;
	    }
	}

	public bool file_move_to_trash(string file_path){

		/* Check and delete file */

		var file = File.new_for_path (file_path);
		if (file.query_exists ()) {
			Posix.system("gvfs-trash '%s'".printf(escape_single_quote(file_path)));
		}
		return true;
	}

	public bool file_shred(string file_path){

		/* Check and delete file */

		var file = File.new_for_path (file_path);
		if (file.query_exists ()) {
			Posix.system("shred -u '%s'".printf(escape_single_quote(file_path)));
		}
		return true;
	}

	public int64 file_line_count (string file_path){
		/* Count number of lines in text file */
		string cmd = "wc -l '%s'".printf(escape_single_quote(file_path));
		string std_out, std_err;
		exec_sync(cmd, out std_out, out std_err);
		return long.parse(std_out.split("\t")[0]);
	}

	public string? file_read (string file_path){

		/* Reads text from file */

		string txt;
		size_t size;

		try{
			GLib.FileUtils.get_contents (file_path, out txt, out size);
			return txt;
		}
		catch (Error e){
	        log_error (e.message);
	        log_error(_("Failed to read file") + ": %s".printf(file_path));
	    }

	    return null;
	}

	public bool file_write (string file_path, string contents, bool overwrite_in_place = false){

		/* Write text to file */

		try{

			dir_create(file_parent(file_path));
			
			var file = File.new_for_path (file_path);

			if (file.query_exists() && overwrite_in_place){

				var iostream = file.open_readwrite();
				//int64 fsize = iostream.query_info("%s".printf(FileAttribute.STANDARD_SIZE)).get_size();
				//iostream.seek (0, GLib.SeekType.END);
				iostream.truncate_fn(0);
				//iostream.seek (0, GLib.SeekType.SET);
				var ostream = iostream.output_stream;
				var data_stream = new DataOutputStream(ostream);
				data_stream.put_string(contents);
				data_stream.close();
			}
			else{

				if (file.query_exists()) {
					file.delete();
				}
	
				var file_stream = file.create (FileCreateFlags.REPLACE_DESTINATION);
				var data_stream = new DataOutputStream (file_stream);
				data_stream.put_string (contents);
				data_stream.close();
			}
			
			return true;
		}
		catch (Error e) {
			log_error(e.message);
			return false;
		}
	}

	public bool file_copy (string src_file, string dest_file, bool follow_symlinks){
		
		try{
			var file_src = File.new_for_path(src_file);
			
			if (file_src.query_exists()) {
				
				var file_dest = File.new_for_path (dest_file);

				var flags = FileCopyFlags.OVERWRITE;

				if (!follow_symlinks){
					flags = flags | FileCopyFlags.NOFOLLOW_SYMLINKS;
				}
				
				file_src.copy(file_dest, flags, null, null);
				return true;
			}
		}
		catch(Error e){
	        log_error (e.message);
	        log_error(_("Failed to copy file") + ": '%s', '%s'".printf(src_file, dest_file));
		}

		return false;
	}

	public bool file_move (string src_file, string dest_file, bool follow_symlinks){
		try{
			var file_src = File.new_for_path (src_file);
			
			if (file_src.query_exists()) {
				
				var file_dest = File.new_for_path (dest_file);

				var flags = FileCopyFlags.OVERWRITE;

				if (!follow_symlinks){
					flags = flags | FileCopyFlags.NOFOLLOW_SYMLINKS;
				}
				
				file_src.move(file_dest, flags, null, null);
				return true;
			}
			else{
				log_error(_("File not found") + ": '%s'".printf(src_file));
				return false;
			}
		}
		catch(Error e){
	        log_error (e.message);
	        log_error(_("Failed to move file") + ": '%s', '%s'".printf(src_file, dest_file));
	        return false;
		}
	}

	public bool file_gzip (string src_file){
		
		string dst_file = src_file + ".gz";
		file_delete(dst_file);
		
		string cmd = "gzip '%s'".printf(escape_single_quote(src_file));
		string std_out, std_err;
		exec_sync(cmd, out std_out, out std_err);
		
		return file_exists(dst_file);
	}

	public bool file_gunzip (string src_file){
		
		string dst_file = src_file;
		file_delete(dst_file);
		
		string cmd = "gunzip '%s'".printf(escape_single_quote(src_file));
		string std_out, std_err;
		exec_sync(cmd, out std_out, out std_err);
		
		return file_exists(dst_file);
	}

	public string file_checksum(string file_path, GLib.ChecksumType checksum_type = ChecksumType.MD5){
		
		var checksum = new Checksum (ChecksumType.MD5);

		if (!file_exists(file_path)){
			return "";
		}
		
		FileStream stream = FileStream.open(file_path, "rb");
		uint8 fbuf[100];
		size_t size;

		while ((size = stream.read (fbuf)) > 0) {
			checksum.update (fbuf, size);
		}

		unowned string digest = checksum.get_string ();
		return digest;
	}
	
	// file info -----------------

	public int64 file_get_size(string file_path){
		try{
			File file = File.parse_name (file_path);
			if (FileUtils.test(file_path, GLib.FileTest.EXISTS)){
				if (FileUtils.test(file_path, GLib.FileTest.IS_REGULAR)
					&& !FileUtils.test(file_path, GLib.FileTest.IS_SYMLINK)){
					return file.query_info("standard::size",0).get_size();
				}
			}
		}
		catch(Error e){
			log_error (e.message);
		}

		return -1;
	}

	public DateTime file_get_modified_date(string file_path){
		try{
			FileInfo info;
			File file = File.parse_name (file_path);
			if (file.query_exists()) {
				info = file.query_info("%s".printf(FileAttribute.TIME_MODIFIED), 0);
				return (new DateTime.from_timeval_utc(info.get_modification_time())).to_local();
			}
		}
		catch (Error e) {
			log_error (e.message);
		}
		
		return (new DateTime.from_unix_utc(0)); //1970
	}
	
	public string file_get_symlink_target(string file_path){
		try{
			FileInfo info;
			File file = File.parse_name (file_path);
			if (file.query_exists()) {
				info = file.query_info("%s".printf(FileAttribute.STANDARD_SYMLINK_TARGET), 0);
				return info.get_symlink_target();
			}
		}
		catch (Error e) {
			log_error (e.message);
		}
		
		return "";
	}

	// directory helpers ----------------------
	
	public bool dir_exists(string dir_path){

		return file_is_dir(dir_path);
	}
	
	public bool dir_create(string dir_path, bool show_message = false){

		/* Creates a directory along with parents */

		try{
			var dir = File.parse_name (dir_path);
			if (dir.query_exists () == false) {
				dir.make_directory_with_parents (null);
				if (show_message){
					log_msg(_("Created directory") + ": %s".printf(dir_path));
				}
			}
			return true;
		}
		catch (Error e) {
			log_error (e.message);
			log_error(_("Failed to create dir") + ": %s".printf(dir_path));
			return false;
		}
	}

	public bool dir_delete(string dir_path, bool show_message = false){
		
		/* Recursively deletes directory along with contents */
		
		if (!dir_exists(dir_path)){ return true; }
		
		string cmd = "rm -rf";
		
		if (show_message){
			cmd += "v";
		}
		
		cmd += " '%s'".printf(escape_single_quote(dir_path));
		
		int status = Posix.system(cmd);
		return (status == 0);
	}

	public bool dir_move_to_trash (string dir_path){
		return file_move_to_trash(dir_path);
	}
	
	public bool dir_is_empty (string dir_path){

		/* Check if directory is empty */

		try{
			bool is_empty = true;
			var dir = File.parse_name (dir_path);
			if (dir.query_exists()) {
				FileInfo info;
				var enu = dir.enumerate_children ("%s".printf(FileAttribute.STANDARD_NAME), 0);
				while ((info = enu.next_file()) != null) {
					is_empty = false;
					break;
				}
			}
			return is_empty;
		}
		catch (Error e) {
			log_error (e.message);
			return false;
		}
	}

	public bool filesystem_supports_hardlinks(string path, out bool is_readonly){
		bool supports_hardlinks = false;
		is_readonly = false;
		
		var test_file = path_combine(path, random_string() + "~");
		
		if (file_write(test_file,"")){
			
			var test_file2 = path_combine(path, random_string() + "~");

			var cmd = "ln '%s' '%s'".printf(
				escape_single_quote(test_file),
				escape_single_quote(test_file2));
				
			log_debug(cmd);

			int status = exec_sync(cmd, null, null);

			cmd = "stat --printf '%%h' '%s'".printf(
				escape_single_quote(test_file));

			log_debug(cmd);
			
			string std_out, std_err;
			status = exec_sync(cmd, out std_out, out std_err);
			log_debug("stdout: %s".printf(std_out));
			
			int64 count = 0;
			if (int64.try_parse(std_out, out count)){
				if (count > 1){
					supports_hardlinks = true;
				}
			}
			
			file_delete(test_file2); // delete if exists
			file_delete(test_file);
		}
		else{
			is_readonly = true;
		}

		return supports_hardlinks;
	}

	public Gee.ArrayList<string> dir_list_names(string path, bool full_path){
		
		var list = new Gee.ArrayList<string>();
		
		try
		{
			File f_path = File.new_for_path (path);

			if (!f_path.query_exists()){ return list; }
			
			FileEnumerator enumerator = f_path.enumerate_children ("%s".printf(FileAttribute.STANDARD_NAME), 0);
			FileInfo file;
			while ((file = enumerator.next_file ()) != null) {
				string name = file.get_name();

				if (full_path){
					list.add(path_combine(path, name));
				}
				else{
					list.add(name);
				}
			}
		}
		catch (Error e) {
			log_error (e.message);
		}

		//sort the list
		CompareDataFunc<string> entry_compare = (a, b) => {
			return strcmp(a,b);
		};
		list.sort((owned) entry_compare);

		return list;
	}

	public Gee.ArrayList<string> dir_list_files_recursive(string path, bool full_path, Gee.ArrayList<string>? file_list = null){

		var list = new Gee.ArrayList<string>();
		 
		if (file_list != null){
			list = file_list;
		}

		try
		{
			File f_path = File.new_for_path (path);

			if (!f_path.query_exists()){ return list; }
			
			FileEnumerator enumerator = f_path.enumerate_children("%s,%s".printf(FileAttribute.STANDARD_NAME, FileAttribute.STANDARD_TYPE), 0);
			FileInfo file;
			while ((file = enumerator.next_file ()) != null) {
				
				string name = file.get_name();
				var type = file.get_file_type();

				if (type == FileType.REGULAR){
					if (full_path){
						list.add(path_combine(path, name));
					}
					else{
						list.add(name);
					}
				}
				else if (type == FileType.DIRECTORY){
					list = dir_list_files_recursive(path_combine(path, name), full_path, list);
				}
			}
		}
		catch (Error e) {
			log_error (e.message);
		}

		//sort the list
		CompareDataFunc<string> entry_compare = (a, b) => {
			return strcmp(a,b);
		};
		list.sort((owned) entry_compare);

		return list;
	}
	
	public bool dir_tar (string src_dir, string tar_file, bool recursion = true){
		if (dir_exists(src_dir)) {
			
			if (file_exists(tar_file)){
				file_delete(tar_file);
			}

			var src_parent = file_parent(src_dir);
			var src_name = file_basename(src_dir);
			
			string cmd = "tar cvf '%s' --overwrite --%srecursion -C '%s' '%s'\n".printf(
				escape_single_quote(tar_file),
				(recursion ? "" : "no-"),
				escape_single_quote(src_parent),
				escape_single_quote(src_name));

			log_debug(cmd);
			
			string stdout, stderr;
			int status = exec_script_sync(cmd, out stdout, out stderr);
			if (status == 0){
				return true;
			}
			else{
				log_msg(stderr);
			}
		}
		else{
			log_error(_("Dir not found") + ": %s".printf(src_dir));
		}

		return false;
	}

	public bool dir_untar (string tar_file, string dst_dir){
		if (file_exists(tar_file)) {

			if (!dir_exists(dst_dir)){
				dir_create(dst_dir);
			}
			
			string cmd = "tar xvf '%s' --overwrite --same-permissions -C '%s'\n".printf(
				escape_single_quote(tar_file),
				escape_single_quote(dst_dir));

			log_debug(cmd);
			
			string stdout, stderr;
			int status = exec_script_sync(cmd, out stdout, out stderr);
			if (status == 0){
				return true;
			}
			else{
				log_msg(stderr);
			}
		}
		else{
			log_error(_("File not found") + ": %s".printf(tar_file));
		}
		
		return false;
	}

	public bool chown(string file_path, string username, string group){

		// Note: chown is recursive, chmod is not. use chmod_dir_contents() for recursive chmod()
		
		string cmd = "chown %s:%s -R -h '%s'".printf(username, group, escape_single_quote(file_path));
		
		log_debug("$ %s".printf(cmd));
		
		int status = exec_sync(cmd, null, null);
		
		return (status == 0);
	}

	public bool chmod(string file_path, string perms){
		
		string cmd = "chmod %s '%s'".printf(perms, escape_single_quote(file_path));
		
		log_debug("$ %s".printf(cmd));
		
		int status = exec_sync(cmd, null, null);
		
		return (status == 0);
	}

	public bool chmod_dir_contents(string dir_path, string type, string perms){

		string cmd = "find '%s'".printf(escape_single_quote(dir_path));

		if (type in "fdl"){
			cmd += " -type %s".printf(type);
		}
		
		cmd += " -exec chmod %s '{}' ';'".printf(perms);
		
		log_debug("$ %s".printf(cmd));
		
		int status = exec_sync(cmd, null, null);
		
		return (status == 0);
	}
	
	// dir info -------------------
	
	// dep: find wc    TODO: rewrite
	public long dir_count(string path){

		/* Return total count of files and directories */

		string cmd = "";
		string std_out;
		string std_err;
		int ret_val;

		cmd = "find '%s' | wc -l".printf(escape_single_quote(path));
		ret_val = exec_script_sync(cmd, out std_out, out std_err);
		return long.parse(std_out);
	}

	// dep: du
	public long dir_size(string path){

		/* Returns size of files and directories in KB*/

		string cmd = "du -s -b '%s'".printf(escape_single_quote(path));
		string std_out, std_err;
		exec_sync(cmd, out std_out, out std_err);
		return long.parse(std_out.split("\t")[0]);
	}

	// dep: du
	public long dir_size_kb(string path){

		/* Returns size of files and directories in KB*/

		return (long)(dir_size(path) / 1024.0);
	}

	// hashing -----------
	
	public string hash_md5(string path){
		Checksum checksum = new Checksum (ChecksumType.MD5);
		FileStream stream = FileStream.open (path, "rb");

		uint8 fbuf[100];
		size_t size;
		while ((size = stream.read (fbuf)) > 0){
		  checksum.update (fbuf, size);
		}
		
		unowned string digest = checksum.get_string();

		return digest;
	}

	// misc --------------------

	public string format_file_size (
		uint64 size, bool binary_units = false,
		string unit = "", bool show_units = true, int decimals = 1){
			
		int64 unit_k = binary_units ? 1024 : 1000;
		int64 unit_m = binary_units ? 1024 * unit_k : 1000 * unit_k;
		int64 unit_g = binary_units ? 1024 * unit_m : 1000 * unit_m;
		int64 unit_t = binary_units ? 1024 * unit_g : 1000 * unit_g;

		string txt = "";
		
		if ((size > unit_t) && ((unit.length == 0) || (unit == "t"))){
			txt += ("%%'0.%df".printf(decimals)).printf(size / (1.0 * unit_t));
			if (show_units){
				txt += " %sB".printf(binary_units ? "Ti" : "T");
			}
		}
		else if ((size > unit_g) && ((unit.length == 0) || (unit == "g"))){
			txt += ("%%'0.%df".printf(decimals)).printf(size / (1.0 * unit_g));
			if (show_units){
				txt += " %sB".printf(binary_units ? "Gi" : "G");
			}
		}
		else if ((size > unit_m) && ((unit.length == 0) || (unit == "m"))){
			txt += ("%%'0.%df".printf(decimals)).printf(size / (1.0 * unit_m));
			if (show_units){
				txt += " %sB".printf(binary_units ? "Mi" : "M");
			}
		}
		else if ((size > unit_k) && ((unit.length == 0) || (unit == "k"))){
			txt += ("%%'0.%df".printf(decimals)).printf(size / (1.0 * unit_k));
			if (show_units){
				txt += " %sB".printf(binary_units ? "Ki" : "K");
			}
		}
		else{
			txt += "%'0lld".printf(size);
			if (show_units){
				txt += " B";
			}
		}

		return txt;
	}

	public string escape_single_quote(string file_path){
		return file_path.replace("'","'\\''");
	}

	// dep: realpath
	public string resolve_relative_path (string filePath){

		/* Resolve the full path of given file using 'realpath' command */

		string filePath2 = filePath;
		if (filePath2.has_prefix ("~")){
			filePath2 = Environment.get_home_dir () + "/" + filePath2[2:filePath2.length];
		}

		try {
			string output = "";
			string cmd = "realpath '%s'".printf(escape_single_quote(filePath2));
			Process.spawn_command_line_sync(cmd, out output);
			output = output.strip ();
			if (FileUtils.test(output, GLib.FileTest.EXISTS)){
				return output;
			}
		}
		catch(Error e){
	        log_error (e.message);
	    }

	    return filePath2;
	}

	public int rsync (string sourceDirectory, string destDirectory, bool updateExisting, bool deleteExtra){

		/* Sync files with rsync */

		string cmd = "rsync -avh";
		cmd += updateExisting ? "" : " --ignore-existing";
		cmd += deleteExtra ? " --delete" : "";
		cmd += " '%s'".printf(escape_single_quote(sourceDirectory) + "//");
		cmd += " '%s'".printf(escape_single_quote(destDirectory));
		return exec_sync (cmd, null, null);
	}
}
