package vault

import (
	"io/ioutil"
	"log"
	"time"
)

const serviceAccountTokenFile = "/var/run/secrets/kubernetes.io/serviceaccount/token"

func (ctrl *controller) Login(vaultRole string) error {
	log.Printf("vault-controller: logging with k8s service account")

	jwt, err := ioutil.ReadFile(serviceAccountTokenFile)

	if err != nil {
		log.Printf("error: Service account token file.")
		return err
	}

	if vaultRole == "" {
		log.Printf("error: Vault role missing.")
		return err
	}

	token, err := ctrl.vclient.Logical().Write("auth/kubernetes/login", map[string]interface{}{
		"jwt":  string(jwt[:]),
		"role": vaultRole,
	})

	if err != nil {
		log.Printf("could not login with service account: %s", err)
		return err
	}

	ctrl.vclient.SetToken(token.Auth.ClientToken)

	ctrl.authTokenRenew(int64(token.Auth.LeaseDuration))

	return nil
}

func (ctrl *controller) authTokenRenew(initialTTL int64) {
	go func(ttl int64) {
		for {
			nextRenewal := time.Duration(ttl) * time.Second / 2
			timer := time.NewTimer(nextRenewal)
			select {
			case <-timer.C:
				s, _ := ctrl.vclient.Auth().Token().RenewSelf(0)
				nextTTL := int64(s.Auth.LeaseDuration)
				nextRenewal = time.Duration(nextTTL/2) * time.Second
				timer.Reset(nextRenewal)
			}
		}
	}(initialTTL)
}
