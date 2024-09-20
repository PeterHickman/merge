package main

// TODO: Remove files from the updates directory

import (
	"flag"
	"fmt"
	ac "github.com/PeterHickman/ansi_colours"
	ep "github.com/PeterHickman/expand_path"
	"github.com/PeterHickman/toolbox"
	"os"
	"path/filepath"
	"strings"
)

var master string
var updates string
var check string
var dry_run bool

func usage() {
	fmt.Println("merge --master <master directory> --updates <updates directory> [--check ???] [--dry-run]")
	fmt.Println("")
	fmt.Println("Copies all the files in <updates directory> into <master directory> for")
	fmt.Println("all files that are missing or have changed. Will also create missing")
	fmt.Println("directories")
	fmt.Println("")
	fmt.Println("By default a changed file is determined by size. The options are")
	fmt.Println("  --check size    -- Compare the files by size, files the same")
	fmt.Println("                     size are considered identical")
	fmt.Println("  --check md5     -- Compare the files by md5 hash, files with")
	fmt.Println("                     the same md5 hashes are considered identical")
	fmt.Println("                     but hash collisions are a thing")
	fmt.Println("  --check sha256  -- Compare the files by sha256 hash, files with")
	fmt.Println("                     the same sha256 hashes are considered identical")
	fmt.Println("  --check same    -- If the files exist they are considerd identical")
	fmt.Println("                     this allows you to only merge the new files")
	fmt.Println("")
	fmt.Println("  --dry-run       -- Report the actions that would be taken but do not")
	fmt.Println("                     do them")
	fmt.Println("")
	fmt.Println("Remember to keep a backup :)")

	os.Exit(1)
}

func same_type(m_info, u_info os.FileInfo) bool {
	return m_info.IsDir() == u_info.IsDir()
}

func different_files(master, updates string, m_info, u_info os.FileInfo) bool {
	if check == "same" {
		return false
	}

	if m_info.Size() == u_info.Size() {
		if check == "size" {
			return false
		} else if check == "md5" {
			return toolbox.CalculateMD5(master) != toolbox.CalculateMD5(updates)
		} else if check == "sha256" {
			return toolbox.CalculateSHA256(master) != toolbox.CalculateSHA256(updates)
		}
	}

	return true
}

func copy_file(orig, update string) {
	fmt.Println("Copy " + ac.Blue(update))
    fmt.Println("  to " + ac.Blue(orig))
    fmt.Println()

	if dry_run {
		return
	}

	r, err := os.Open(update)
	if err != nil {
		fmt.Println(ac.Red(err.Error()))
		os.Exit(8)
	}
	defer r.Close()

	w, err := os.Create(orig)
	if err != nil {
		fmt.Println(ac.Red(err.Error()))
		os.Exit(9)
	}
	defer w.Close()

	w.ReadFrom(r)
}

func make_directory(path string) {
	fmt.Println("New directory " + ac.Blue(path))

	if dry_run {
		return
	}

	if err := os.Mkdir(path, os.ModePerm); err != nil {
		fmt.Println(err)
		os.Exit(7)
	}
}

func show(info os.FileInfo) string {
	if info.IsDir() {
		return "directory"
	} else {
		return "file"
	}
}

func init() {
	var m = flag.String("master", "", "The directory we are keeping up to date")
	var u = flag.String("updates", "", "The directory of updates")
	var c = flag.String("check", "size", "How to compare files")
	var d = flag.Bool("dry-run", false, "Do not copy files, just report what would happen")

	flag.Parse()

	if *m == "" || *u == "" {
		usage()
	}

	dry_run = *d

	check = strings.ToLower(*c)

	if check != "size" && check != "md5" && check != "sha256" && check != "same" {
		usage()
	}

	master, _ = ep.ExpandPath(*m)
	if !toolbox.FileExists(master) {
		fmt.Println("The directory " + master + " does not exist")
		os.Exit(2)
	}

	updates, _ = ep.ExpandPath(*u)
	if !toolbox.FileExists(updates) {
		fmt.Println("The directory " + updates + " does not exist")
		os.Exit(3)
	}

	if master == updates {
		fmt.Println("--master and --updates cannot be the same directory")
		os.Exit(4)
	}
}

func main() {
	fmt.Println("Master ...: " + master)
	fmt.Println("Updates ..: " + updates)
	fmt.Println("Check ....: " + check)
	fmt.Printf("Dry run ..: %t\n", dry_run)

	err := filepath.Walk(updates,
		func(path string, info os.FileInfo, err error) error {
			if err != nil {
				return err
			}

			name := path[len(updates):]
			if name == "" {
				return nil
			}

			m := master + name
			u := path

			m_info, _ := os.Stat(m)
			u_info, _ := os.Stat(u)

			if toolbox.FileExists(m) {
				if same_type(m_info, u_info) {
					if !m_info.IsDir() {
						if different_files(m, u, m_info, u_info) {
							copy_file(m, u)
						}
					}
				} else {
					fmt.Println(ac.Red(m + " is a " + show(m_info) + ", whereas " + u + " is a " + show(u_info)))
				}
			} else if u_info.IsDir() {
				make_directory(m)
			} else {
				copy_file(m, u)
			}

			return nil
		})

	if err != nil {
		fmt.Println(err)
		os.Exit(6)
	}
}
