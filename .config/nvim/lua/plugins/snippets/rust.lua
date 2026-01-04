-- ~/.config/nvim/luasnippets/rust.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("afn", {
    t("async fn "),
    i(1, "name"),
    t("("),
    i(2, "args"),
    t(") -> "),
    i(3, "Result<(), Box<dyn std::error::Error>>"),
    t({ " {", "    " }),
    i(0, "// code"),
    t({ "", "}" }),
  }),

  s("lsall", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn list_all<P: AsRef<Path>>(dir: P) -> Result<Vec<String>, Box<dyn Error>> {",
      "    let mut results = Vec::new();",
      "    for entry in fs::read_dir(dir)? {",
      "        let entry = entry?;",
      "        results.push(entry.path().display().to_string());",
      "    }",
      "    Ok(results)",
      "}",
    }),
  }),

  s("lsfiles", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn list_files<P: AsRef<Path>>(dir: P) -> Result<Vec<String>, Box<dyn Error>> {",
      "    let mut results = Vec::new();",
      "    for entry in fs::read_dir(dir)? {",
      "        let entry = entry?;",
      "        let path = entry.path();",
      "        if path.is_file() {",
      "            results.push(path.display().to_string());",
      "        }",
      "    }",
      "    Ok(results)",
      "}",
    }),
  }),

  s("lsdirs", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn list_dirs<P: AsRef<Path>>(dir: P) -> Result<Vec<String>, Box<dyn Error>> {",
      "    let mut results = Vec::new();",
      "    for entry in fs::read_dir(dir)? {",
      "        let entry = entry?;",
      "        let path = entry.path();",
      "        if path.is_dir() {",
      "            results.push(path.display().to_string());",
      "        }",
      "    }",
      "    Ok(results)",
      "}",
    }),
  }),

  s("currentdir", {
    t({
      "use std::env;",
      "use std::io;",
      "use std::path::PathBuf;",
      "",
      "pub fn current_dir() -> Result<PathBuf, io::Error> {",
      "    env::current_dir()",
      "}",
    }),
  }),

  s("homedir", {
    t({
      "use std::env;",
      "use std::path::PathBuf;",
      "",
      "fn home_dir() -> Option<PathBuf> {",
      '    #[cfg(target_family = "windows")]',
      "    {",
      '        if let Some(v) = env::var_os("USERPROFILE") {',
      "            return Some(PathBuf::from(v));",
      "        }",
      '        let drive = env::var_os("HOMEDRIVE");',
      '        let path = env::var_os("HOMEPATH");',
      "        if let (Some(d), Some(p)) = (drive, path) {",
      "            return Some(PathBuf::from(PathBuf::from(d).join(p)));",
      "        }",
      "    }",
      "",
      '    #[cfg(target_family = "unix")]',
      "    {",
      '        if let Some(home) = env::var_os("HOME") {',
      "            return Some(PathBuf::from(home));",
      "        }",
      "    }",
      "",
      "    None",
      "}",
    }),
  }),

  s("pldp", {
    t('println!("{:#?}", '),
    i(1, "var"),
    t(");"),
    i(0),
  }),

  s("perr", {
    t('eprintln!("'),
    i(1, "msg"),
    t('");'),
    i(0),
  }),

  s("dbg", {
    t("let "),
    i(1, "val"),
    t(" = "),
    i(2, "expr"),
    t({ ";", "let " }),
    i(3, "_"),
    t(" = dbg!(&"),
    t(""),
    i(1),
    t({ ");", "" }),
    i(0),
  }),

  s("rmain", {
    t({
      "use std::error::Error;",
      "",
      "fn main() -> Result<(), Box<dyn Error>> {",
      "    ",
    }),
    i(0, "// code"),
    t({ "", "    Ok(())", "}" }),
  }),

  s("enum", {
    t("enum "),
    i(1, "Kind"),
    t({ " {", "    " }),
    i(2, "Variant1"),
    t({ ",", "    " }),
    i(3, "Variant2("),
    i(4, "T"),
    t({ ")", ",", "}" }),
    i(0),
  }),

  s("implt", {
    t("impl "),
    i(1, "Trait"),
    t(" for "),
    i(2, "Type"),
    t({ " {", "    fn " }),
    i(3, "method"),
    t("(&self"),
    i(4),
    t(") -> "),
    i(5, "()"),
    t({ " {", "        " }),
    i(0, "// code"),
    t({ "", "    }", "}" }),
  }),

  s("derive", {
    t({ "#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]", "" }),
    i(0),
  }),

  s("matchr", {
    t("match "),
    i(1, "res"),
    t({ " {", "    Ok(" }),
    i(2, "val"),
    t(") => "),
    i(3, "/* handle ok */"),
    t({ ",", "    Err(" }),
    i(4, "e"),
    t(") => "),
    i(0, "/* handle err */"),
    t({ ",", "}" }),
  }),

  s("fori=", {
    t("for "),
    i(1, "i"),
    t(" in 0..="),
    i(2, "n"),
    t({ " {", "    " }),
    i(0, "// code"),
    t({ "", "}" }),
  }),
  -- #[cfg(test)] module + một test
  s("tmod", {
    t({ "#[cfg(test)]", "mod tests {", "    use super::*;", "", "    #[test]", "    fn " }),
    i(1, "works"),
    t({ "() {", "        " }),
    i(0, "// arrange/act/assert"),
    t({ "", "    }", "}" }),
  }),

  -- unit test nhanh
  s("t", {
    t({ "#[test]", "fn " }),
    i(1, "works"),
    t({ "() {", "    " }),
    i(0),
    t({ "", "}" }),
  }),

  -- struct + impl::new
  s("snew", {
    t({ "#[derive(Debug, Clone, PartialEq, Eq)]", "struct " }),
    i(1, "Name"),
    t({ " {", "    " }),
    i(2, "field: i32"),
    t({ "", "}", "", "impl " }),
    i(1),
    t({ " {", "    pub fn new(" }),
    i(3, "field: i32"),
    t({ ") -> Self {", "        Self { " }),
    i(4, "field"),
    t({ " }", "    }", "}" }),
  }),

  -- impl Default
  s("impld", {
    t({ "impl Default for " }),
    i(1, "Name"),
    t({ " {", "    fn default() -> Self {", "        Self { " }),
    i(2, "field: 0"),
    t({ " }", "    }", "}" }),
  }),

  -- main async với tokio
  s("tokio", {
    t({ "#[tokio::main]", "async fn main() -> anyhow::Result<()> {", "    " }),
    i(0, "// code"),
    t({ "", "    Ok(())", "}" }),
  }),

  -- clap derive CLI
  s("clap", {
    t({ "use clap::Parser;", "", "/// " }),
    i(1, "Mô tả ứng dụng"),
    t({ "", "#[derive(Parser, Debug)]", "struct Args {", "    /// " }),
    i(2, "Input file"),
    t({
      "",
      "    #[arg(short, long)]",
      "    input: String,",
      "}",
      "",
      "fn main() {",
      "    let args = Args::parse();",
      '    println!("{:?}", args);',
      "}",
    }),
  }),

  -- serde derive struct
  s("serde", {
    t({ "use serde::{Serialize, Deserialize};", "", "#[derive(Debug, Serialize, Deserialize)]", "struct " }),
    i(1, "Model"),
    t({ " {", "    " }),
    i(0, "id: u64"),
    t({ "", "}" }),
  }),

  -- match Option
  s("matcho", {
    t({ "match " }),
    i(1, "opt"),
    t({ " {", "    Some(" }),
    i(2, "v"),
    t({ ") => " }),
    i(3, 'println!("{}", v)'),
    t({ ",", "    None => " }),
    i(0, 'println!("none")'),
    t({ ",", "}" }),
  }),

  -- for enumerate
  s("foren", {
    t({ "for (i, item) in " }),
    i(1, "items.iter().enumerate()"),
    t({ ") {", "    " }),
    i(0, 'println!("{i}: {:?}", item)'),
    t({ "", "}" }),
  }),

  -- module skeleton
  s("modr", {
    t({ "pub mod " }),
    i(1, "name"),
    t({ " {", "    " }),
    i(0, "// pub fn ..."),
    t({ "", "}" }),
  }),

  -- check extension of file
  s("checkext", {
    t({
      "use std::path::Path;",
      "",
      "pub fn has_extension(path: &str, ext: &str) -> bool {",
      "    Path::new(path)",
      "        .extension()",
      "        .and_then(|e| e.to_str())",
      "        .map(|e| e.eq_ignore_ascii_case(ext))",
      "        .unwrap_or(false)",
      "}",
    }),
  }),

  -- List all entries
  s("lsall", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn list_all<P: AsRef<Path>>(dir: P) -> Result<Vec<String>, Box<dyn Error>> {",
      "    let mut results = Vec::new();",
      "    for entry in fs::read_dir(dir)? {",
      "        let entry = entry?;",
      "        results.push(entry.path().display().to_string());",
      "    }",
      "    Ok(results)",
      "}",
    }),
  }),

  -- List only files
  s("lsfiles", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn list_files<P: AsRef<Path>>(dir: P) -> Result<Vec<String>, Box<dyn Error>> {",
      "    let mut results = Vec::new();",
      "    for entry in fs::read_dir(dir)? {",
      "        let entry = entry?;",
      "        let path = entry.path();",
      "        if path.is_file() {",
      "            results.push(path.display().to_string());",
      "        }",
      "    }",
      "    Ok(results)",
      "}",
    }),
  }),

  -- List only directories
  s("lsdirs", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn list_dirs<P: AsRef<Path>>(dir: P) -> Result<Vec<String>, Box<dyn Error>> {",
      "    let mut results = Vec::new();",
      "    for entry in fs::read_dir(dir)? {",
      "        let entry = entry?;",
      "        let path = entry.path();",
      "        if path.is_dir() {",
      "            results.push(path.display().to_string());",
      "        }",
      "    }",
      "    Ok(results)",
      "}",
    }),
  }),

  -- List by extension
  s("lsext", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn list_by_extension<P: AsRef<Path>>(dir: P, ext: &str) -> Result<Vec<String>, Box<dyn Error>> {",
      "    let mut results = Vec::new();",
      "    for entry in fs::read_dir(dir)? {",
      "        let entry = entry?;",
      "        let path = entry.path();",
      "        if path.is_file() {",
      "            if let Some(e) = path.extension() {",
      "                if e == ext {",
      "                    results.push(path.display().to_string());",
      "                }",
      "            }",
      "        }",
      "    }",
      "    Ok(results)",
      "}",
    }),
  }),

  -- Recursive walk
  s("walkdir", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn walk_dir<P: AsRef<Path>>(dir: P) -> Result<Vec<String>, Box<dyn Error>> {",
      "    let mut results = Vec::new();",
      "    for entry in fs::read_dir(dir)? {",
      "        let entry = entry?;",
      "        let path = entry.path();",
      "        results.push(path.display().to_string());",
      "        if path.is_dir() {",
      "            results.extend(walk_dir(path)?);",
      "        }",
      "    }",
      "    Ok(results)",
      "}",
    }),
  }),

  -- File sizes
  s("filesizes", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn file_sizes<P: AsRef<Path>>(dir: P) -> Result<Vec<(String, u64)>, Box<dyn Error>> {",
      "    let mut results = Vec::new();",
      "    for entry in fs::read_dir(dir)? {",
      "        let entry = entry?;",
      "        let path = entry.path();",
      "        if path.is_file() {",
      "            let size = fs::metadata(&path)?.len();",
      "            results.push((path.display().to_string(), size));",
      "        }",
      "    }",
      "    Ok(results)",
      "}",
    }),
  }),

  -- Last modified
  s("lastmod", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "use std::time::SystemTime;",
      "",
      "pub fn last_modified<P: AsRef<Path>>(path: P) -> Result<SystemTime, Box<dyn Error>> {",
      "    let metadata = fs::metadata(path)?;",
      "    Ok(metadata.modified()?)",
      "}",
    }),
  }),

  -- Copy file
  s("copyfile", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn copy_file<P: AsRef<Path>>(src: P, dest: P) -> Result<(), Box<dyn Error>> {",
      "    fs::copy(src, dest)?;",
      "    Ok(())",
      "}",
    }),
  }),

  -- Move file
  s("movefile", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn move_file<P: AsRef<Path>>(src: P, dest: P) -> Result<(), Box<dyn Error>> {",
      "    fs::rename(src, dest)?;",
      "    Ok(())",
      "}",
    }),
  }),

  -- Remove path
  s("rmpath", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn remove_path<P: AsRef<Path>>(path: P) -> Result<(), Box<dyn Error>> {",
      "    let path = path.as_ref();",
      "    if path.is_file() {",
      "        fs::remove_file(path)?;",
      "    } else if path.is_dir() {",
      "        fs::remove_dir_all(path)?;",
      "    }",
      "    Ok(())",
      "}",
    }),
  }),

  -- Exists
  s("exists", {
    t({
      "use std::path::Path;",
      "",
      "pub fn exists<P: AsRef<Path>>(path: P) -> bool {",
      "    path.as_ref().exists()",
      "}",
    }),
  }),

  -- Count entries
  s("countentries", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn count_entries<P: AsRef<Path>>(dir: P) -> Result<usize, Box<dyn Error>> {",
      "    Ok(fs::read_dir(dir)?.count())",
      "}",
    }),
  }),

  -- Read file to string
  s("readfile", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn read_file<P: AsRef<Path>>(path: P) -> Result<String, Box<dyn Error>> {",
      "    Ok(fs::read_to_string(path)?)",
      "}",
    }),
  }),

  -- Write file
  s("writefile", {
    t({
      "use std::error::Error;",
      "use std::fs;",
      "use std::path::Path;",
      "",
      "pub fn write_file<P: AsRef<Path>>(path: P, contents: &str) -> Result<(), Box<dyn Error>> {",
      "    fs::write(path, contents)?;",
      "    Ok(())",
      "}",
    }),
  }),

  -- Append file
  s("appendfile", {
    t({
      "use std::error::Error;",
      "use std::fs::OpenOptions;",
      "use std::io::Write;",
      "use std::path::Path;",
      "",
      "pub fn append_file<P: AsRef<Path>>(path: P, contents: &str) -> Result<(), Box<dyn Error>> {",
      "    let mut file = OpenOptions::new().append(true).create(true).open(path)?;",
      "    file.write_all(contents.as_bytes())?;",
      "    Ok(())",
      "}",
    }),
  }),
}
