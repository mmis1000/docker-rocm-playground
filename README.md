# AMD ROCm Unraid Playground

This Docker container provides a fully functional AMD ROCm environment with proper signal handling, SSH access, and FFmpeg hardware acceleration debugging tools.

## 1. Building the Image

If you are building this image directly on your Unraid server via SSH or a local machine to push to a registry:

```bash
docker build -t my-rocm-playground .
```

## 2. Deploying on Unraid

To run this inside Unraid, you can either use the command line or translate this into an Unraid Docker Template.

### Docker Run Command (via Unraid Terminal)

```bash
docker run -d \
  --name rocm-playground \
  --privileged \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add video \
  --group-add render \
  --security-opt seccomp=unconfined \
  -e GITHUB_USER="your-github-username" \
  -p 2222:22 \
  my-rocm-playground
```

### Unraid WebUI Template Mapping:
If you are adding this via the Unraid "Add Container" WebUI, make sure to add the following parameters:

* **Extra Parameters (Advanced View):** `--device=/dev/kfd --device=/dev/dri --group-add video --group-add render --security-opt seccomp=unconfined`
* **Variable:** Name: `GITHUB_USER`, Key: `GITHUB_USER`, Value: `your-github-username`
* **Port:** Host Port: `2222`, Container Port: `22`

## 3. Testing Hardware Acceleration

Once the container is running, SSH into it (using the private key associated with your GitHub account):

```bash
ssh -p 2222 root@<YOUR_UNRAID_IP>
```

Run the following commands to verify hardware access:

* **Check AMD ROCm GPU Status:** `rocm-smi`
* **Check Video Acceleration (VA-API):** `vainfo`
* **Monitor GPU Utilization:** `radeontop`
* **Check FFmpeg HW Decoders:** `ffmpeg -decoders | grep vaapi`
