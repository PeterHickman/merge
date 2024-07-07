package main

// TODO: Check file differences on more that file size. md5? sha256?
// TODO: A dry run flag
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

func usage() {
	fmt.Println("merge -master <master directory> -updates <updates directory>")
	fmt.Println("")
	fmt.Println("Copies all the files in <updates directory> into <master directory> for")
	fmt.Println("all files that are missing or have changed. Will also create missing")
	fmt.Println("directories")
	fmt.Println("")
	fmt.Println("By default a changed file is determined by size, --check can be either md5 or sha256")
	fmt.Println("")
	fmt.Println("Remember to keep a backup :)")

	os.Exit(1)
}

func same_type(m_info, u_info os.FileInfo) bool {
	return m_info.IsDir() == u_info.IsDir()
}

func same_size(m_info, u_info os.FileInfo) bool {
	return m_info.Size() == u_info.Size()
}

func copy_file(orig, update string) {
	fmt.Println("Copy " + ac.Blue(update) + " ==> " + ac.Blue(orig))

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

	flag.Parse()

	if *m == "" || *u == "" {
		usage()
	}

	check := strings.ToLower(*c)

	if check != "size" && check != "md5" && check != "sha256" {
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
						if !same_size(m_info, u_info) {
							copy_file(m, u)
						}
					}
				} else {
					fmt.Println(ac.Red(m + " is a " + show(m_info) + ", whereas " + u + " is a " + show(u_info)))
				}
			} else if u_info.IsDir() {
				fmt.Println(ac.Blue(m) + " is new directory")
				if err := os.Mkdir(m, os.ModePerm); err != nil {
					fmt.Println(err)
					os.Exit(7)
				}
			} else {
				fmt.Println(ac.Blue(m) + " is new file")
				copy_file(m, u)
			}

			return nil
		})

	if err != nil {
		fmt.Println(err)
		os.Exit(6)
	}
}
