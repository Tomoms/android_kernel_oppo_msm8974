#include <linux/fs.h>
#include <linux/init.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>

#ifdef CONFIG_SAMSUNG_LPM_MODE
extern int poweroff_charging;
#endif

static int cmdline_proc_show(struct seq_file *m, void *v)
{
#ifdef CONFIG_SAMSUNG_LPM_MODE
	if (poweroff_charging) {
		seq_printf(m, "%s %s\n", saved_command_line,
				"androidboot.mode=charger");
		return 0;
	}
#endif
	seq_printf(m, "%s\n", saved_command_line);
	return 0;
}

static int cmdline_proc_open(struct inode *inode, struct file *file)
{
	return single_open(file, cmdline_proc_show, NULL);
}

static const struct file_operations cmdline_proc_fops = {
	.open		= cmdline_proc_open,
	.read		= seq_read,
	.llseek		= seq_lseek,
	.release	= single_release,
};

static int __init proc_cmdline_init(void)
{
	char *offset_addr;

	offset_addr = strstr(saved_command_line, "androidboot.mode=reboot");
	if (offset_addr != NULL)
		strncpy(offset_addr + 17, "normal", 6);

	proc_create("cmdline", 0, NULL, &cmdline_proc_fops);
	return 0;
}
module_init(proc_cmdline_init);
